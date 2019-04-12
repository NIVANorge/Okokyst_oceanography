# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#
# 1. Libraries, scripts ----
#
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

library(ncdf4)
library(tidyverse)
library(ggmap)
library(readxl)

# Function that needs to be run for plotting using image() or image.plot()
transpose_for_image <- function(x) t(x[seq(nrow(x),1,-1),])

# Load function okokyst_read_nc()
source("02_Read_all_functions.R")

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#
# 2 Data folder, files ----
#
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

folder_data <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017"

# Files (a minute or two)
fn_nc <- dir(folder_data, "*.nc$", recursive = TRUE)
fn_nc
length(fn_nc)  # 174

# not needed
# fn_full <- paste0(folder_data, "/", fn_nc)  

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#
# 3. Testing info inside netcdf file ----
#
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

ncin <- nc_open(paste0(folder_data, "/", fn_nc[1]))

# station data
lon = ncvar_get(ncin,"lon")
lat = ncvar_get(ncin,"lat")

# Depths
z     <- ncin$dim$depth$vals
z_nut <- ncin$dim$depth_nut$vals

names(ncin$var)                       # Show variable names
# purrr::transpose(ncin$var)$longname   # Show variable long names
# str(ncin, 1)                          # Show file contents

names(ncin$var)                       # Show variable names
purrr::transpose(ncin$var)$longname   # Show variable long names
purrr::transpose(ncin$var)$units      # Show units
ncin$var[["temp"]]$dim[[1]]$name      # Get which depth dimension we should use

# How to get the right depth for the chosen variable
varname <- "temp"
varname <- "TotP"
varname <- "depth2"
varname <- "KlfA_5m"
dim1_var <- ncin$var[[varname]]$dim[[1]]$name  
dim1 <- ncin$dim[[dim1_var]]$vals
dim1

# Number of dimensions
names(ncin$var) %>% map_int(~length(ncin$var[[.]]$dim))

# All 'dim1_var'
names(ncin$var) %>% map_chr(~ncin$var[[.]]$dim[[1]]$name)

# purrr::transpose(ncin$var)$longname   # Show variable long names
# str(ncin, 1)                          # Show file contents

nc_close(ncin)

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#
# 4. Test reads using okokyst_read_nc2 ---- 
#    (like okokyst_read_nc, but more general)
#
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

fn_nc[1]
# [1] "Glomfjord_data/ncbase_Glomfjord/Gl-1_2017.nc"

# a CTD variable (data every meter depth)
df1 <- okokyst_read_nc2(fn_nc[1], "salt", folder_data = folder_data)
ggplot(df1, aes(Value, Depth, group =factor(Time), color = factor(Time))) +
  geom_path() + 
  scale_y_reverse()

# a nutrient variable (4 dephts)
df2 <- okokyst_read_nc2(fn_nc[1], "TotP", folder_data = folder_data)
ggplot(df2 %>% filter(Value < 10000), aes(Value, Depth, group =factor(Time), color = factor(Time))) +
  geom_path() + 
  scale_y_reverse()

# a variable without depth (time only)
df3 <- okokyst_read_nc2(fn_nc[1], "secchi", folder_data = folder_data)
ggplot(df3, aes(Time, Value)) + geom_path()

# time_nut
df4 <- okokyst_read_nc2(fn_nc[1], "time_nut", folder_data = folder_data)

# Test combining (glue rows together)
df_comb <- bind_rows(df1, df2, df3, df4)
table(df_comb$Variable)
nrow(df_comb) # 1908

# Test spread (from tall to broad file)
df_comb_spread <- tidyr::spread(df_comb, Variable, Value)
head(df_comb_spread)
dim(df_comb_spread)  # 1854, 10
apply(!is.na(df_comb_spread), 2, sum)
df_comb_spread %>% filter(Depth %in% 5)  # check 5 m, where there is both CTD and nutrient data
# Check the extra variable 'time_nut' 
# Usually, but not always the same as "Time"! 
# Nutrients 2017-01-02 is paired with time 2017-01-04. So this is extra information that can be useful and should be included
df <- df_comb_spread %>% filter(!is.na(time_nut_unix))
df$time_nut_unix <- as.POSIXct(df$time_nut_unix, origin = "1970-01-01", tz = "GMT")
with(df, Time - time_nut_unix)
df[c("Time", "time_nut_unix")]

df_comb_spread %>% filter(salt_PSU < 10000) %>%
  ggplot(aes(salt_PSU, Depth, group =factor(Time), color = factor(Time))) +
  geom_path() + 
  scale_y_reverse()

df_comb_spread %>% filter(`TotP_micro g P/L` < 10000) %>%
  ggplot(aes(`TotP_micro g P/L`, Depth, group =factor(Time), color = factor(Time))) +
  geom_path() + 
  scale_y_reverse()

ggplot(df_comb_spread, aes(Time, secchi_m)) + geom_path()

# df <- okokyst_readall_nc(fn, folder_data = datafolder, report = TRUE)       # a CTD variable (data every meter depth)

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#
# Read all data from one file ----
# 
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

# Get data in tidy format
df1 <- okokyst_readall_nc(fn_nc[1], folder_data = folder_data, report = TRUE)
table(df1$Variable)
nrow(df1)

# Check a Skagerrak file
# debugonce(okokyst_readall_nc)
df2 <- okokyst_readall_nc("OKOKYST_Skagerrak/ncbase/2018/VT68/VT68_2018.nc", folder_data = folder_data, report = TRUE)
table(df2$Variable)
nrow(df2)

# Check a Ferrybox file
# debugonce(okokyst_readall_nc)
df3 <- okokyst_readall_nc("OKOKYST_Ferrybox/ncbase/VT80/VT80_2017_2018.nc" , folder_data = folder_data, report = TRUE)
table(df3$Variable)
nrow(df3)

# Combine
df_comb <- bind_rows(df1, df2, df3)
table(df_comb$Variable)  # 36 variables

# Spread (from tall to broad file)
df_comb_spread <- tidyr::spread(df_comb, Variable, Value)
head(df_comb_spread)

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#
# Filter file names ----
# 
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

# Check those with 'ncbase' and not in folder Test
sel1 <- grepl("ncbase", fn_nc)
sel2 <- grepl("/Tools/", fn_nc, fixed = TRUE)
sel <- sel1 & !sel2
sum(sel)
mean(sel)
fn_nc[!sel]
fn_nc[sel]

# Check one station
selx <- grepl("VT67", fn_nc)
fn_nc[selx]

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#
# Filter file names ----
# 
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

# Use safely
# Remove 1:6 and run for all, but first fix error below
okokyst_readall_nc_safe <- safely(okokyst_readall_nc)
df_comb_list <- fn_nc[sel][1:6] %>% map(~okokyst_readall_nc_safe(., folder_data = folder_data, report = TRUE))
str(df_comb_list, 2)
transpose(df_comb_list)$error

# file no 5 contains "time_of_cast", gives error 
# df1 <- okokyst_read_nc2(fn_nc[5], "time_of_cast", folder_data = folder_data)

