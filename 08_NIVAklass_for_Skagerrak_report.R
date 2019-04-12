# BAsed on script 07 but for Skagerrak historic (2013-2017) data, in order to
#  fix an erronous 90 percentile value fro Chl a


# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
# Load libraries ----
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

library(ncdf4)      # functions for NCDF files
library(dplyr)      # for group_by(), summarize(), the %>% operator and more
library(tidyr)      # for spread()
library(xlsx)       # read/write to Excel
library(lubridate)  # time functions (year, month, ymd_hms etc.)
library(ggplot2)    # plotting

# Load function okokyst_read_nc()
source("02_Read_all_functions.R")


# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
# Define folder, file name and name of station ----
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

# # Check folder names
# dir("K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017")            # VR31_2014_2018
# 
# # Define folder
# folder_data <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor2_SNO/ncbase/2018"
# 
# # Check file names
# dir(folder_data, "*.nc")
# 
# # Define file name and station name
# fn <- "VR31_2014_2018.nc"
# name ='Tilremsfjorden'

# For Skagerrak historic
# See 
# "K:\Prosjekter\Sjøvann\KYSTOVERVÅKING ØKOKYST\KYSTOVERVÅKING ØKOKYST 2017-2020\ØKOKYST DP Skagerrak O-17089_19089\Årsrapport2018\Årsrapport 2018 data\Vannmassene\NIVAclass\NIVAklass_VT10.m"
# 
folder_data <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_Skagerrak/xlsbase_Vannmiljo" # /VT10_2013_2016.nc"
dir(folder_data, "*.nc")
fn <- "VT10_2013_2016.nc"
name ='VT10'

# Extract station code from file name, assuming that it is on the form "code_year_year"
# I.e. extracting everything to the left of the first underscore
code <- stringr::str_extract(fn, "^[^_]+(?=_)")

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#  Read station data and depth ----
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

ncin <- nc_open(paste0(folder_data, "/", fn))

# station data
lon = ncvar_get(ncin,"lon")
lat = ncvar_get(ncin,"lat")

# Print station info
cat(code, ": ", name, " N", lat, " E", lon, "\n", sep = "")

# Depths
z     <- ncin$dim$depth$vals
z_nut <- ncin$dim$depth_nut$vals

nc_close(ncin)

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
# Check file info ----
# If necessary
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

# names(ncin$var)                       # Show variable names
# purrr::transpose(ncin$var)$longname   # Show variable long names
# str(ncin, 1)                          # Show file contents

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#  WE SKIP Oxygen in the deep water etc.
#  and go straght to Chl A
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o


# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==
#  Klorofyll A ----
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==
#  Calculate average for 0-10m according to Veileder 02:2018
#  Earlier only 5 m was used
#  Data from 0, 5, 10 is used
#  Formula:
# 
#  C(0-10) = (1/4)*C0 + (2/4)*C5 + (1/4)*C10
# 
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==


# Original (script 07):
# Weights (will be used for weighted average)
# weights_chla <- data.frame(
#   Depth = c(0, 5, 10),
#   Weight = c(1/4, 2/4, 1/4)
# )

# Read data, add weights (will be used for weighted average), and keep only 0-10 m data (remove Weight = NA)

# Original (script 07):
# KlfA <- okokyst_read_nc(fn, "KlfA", ctd_variable = FALSE) %>%
#  left_join(weights_chla, by = "Depth") %>% filter(!is.na(Weight)) 

# For Skagerrak historic data:
# No 'depth_nut' variable for the nutrent depths, that is inside 'depth' actually
# We use depth by setting ctd_variable = TRUE
# debugonce(okokyst_read_nc)
KlfA <- okokyst_read_nc(fn, "KlfA", ctd_variable = TRUE, read_depth_nut = FALSE)

# Original (script 07):
# Weighted average over depths, per sampling occasion
# uKlfA   <- KlfA %>% 
#   group_by(Time) %>% 
#   summarize(Average = sum(KlfA*Weight)) %>%
#   mutate(Year = year(Time), 
#          Month = month(Time)
#          )

# For Skagerrak historic data:
# % Klorofyll a
# % Use maximum value in the depth interval 0-10m
# uKlfA_1=nanmax(KlfA_1(:,1:4),[],2); 
#
# 'Average' replaced by 'Klfa_max' for rest of script!
#
uKlfA   <- KlfA %>%
  filter(Depth <= 10) %>%
  group_by(Time) %>%
  summarize(Klfa_max = max(KlfA, na.rm = TRUE)) %>%
  mutate(Year = year(Time),
         Month = month(Time)
         )

# Plot for sanity check 
ggplot(KlfA, aes(Time, KlfA, color = factor(Depth))) + geom_line() + geom_point() +
  geom_line(data = uKlfA, aes(y = Klfa_max), color = "black", size = 1)


# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==
#  Klorofyll A, get 90 percentile value ----
#  This method need spesial attention if NaN exist in the 
#  profiles
#
#  90 percentile value (differs from perctile.exc in excel)
# PERCENTILE.EXC in Excel:
# https://support.office.com/en-us/article/percentile-exc-function-bbaa7204-e9e1-4010-85bf-c31dc5dce4ba
# which corresponds to quantile type 6 according to https://www.r-bloggers.com/the-problem-with-percentiles-2/ 
# 
# BUT: see appendix at bottom of this file
#
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==

percentile_type <- 7
# Run ?quantile for description of types. Also see appendix at end of this file

if (lat > 62){
  include_months <- 3:9
} else {
  include_months <- 2:10
}

data_klfa_year <- uKlfA %>%
  filter(Month %in% include_months) %>%   # Mars til Spetember, se s. 138 i Veileder 02:2018
  group_by(Year) %>%
  summarize(Value = quantile(Klfa_max, 0.9, type = percentile_type))

# Another plot for sanity check
# Depth averaged data for selected months showns as black dots
# Annual 90th percentiles (based on selected months) showns as black dots
ggplot(KlfA, aes(Time, KlfA, color = factor(Depth))) + geom_line() + geom_point() +
  geom_point(data = uKlfA %>% filter(Month %in% include_months), aes(y = Klfa_max), color = "black", size = 2) +
  geom_point(data = data_klfa_year, aes(x = ymd_hms(paste(Year, "07 01 00:00:00")), y = Value), size = 3, color = "red")
