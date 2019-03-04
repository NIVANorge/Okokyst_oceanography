
# 1. Libraries ----

library(ncdf4)
library(dplyr)
library(ggplot2)
library(readxl)
# library(MBA)    # Interpolation using multilevel b-spline
library(akima)    # Interpolation

# Function that needs to be run for plotting using image() or image.plot()
transpose_for_image <- function(x) t(x[seq(nrow(x),1,-1),])

# Load function okokyst_read_nc()
source("02_Read_all_functions.R")

# 2. Get station attributes ----
fn <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_Hydrografi_Stasjoner_v5.xlsx"
df_stations <- read_excel(fn) %>% 
  rename(ProjectName = ProjcetName)


# Two stations with same name
df_stations$StationName[c(9,18)]  # "Korsfjorden" "Korsfjorden"
df_stations$StationName[9] <- "Korsfjorden_Hord"
df_stations$StationName[18] <- "Korsfjorden_Trønd"

## Test reads
### 3. Test read 1 ----

dir("K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017")
folder_data <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor1_RMS/ncbase/2018"
dir(folder_data, "*.nc")

df <- okokyst_read_nc("VR51_2017_2018.nc", "salt", ctd_variable = TRUE)

#
# 4. Test plotting ----
#
# Can be skipped! (Jump to 5)
#
# Plot as points

gg <- ggplot(df, aes(Time, Depth)) +
  geom_point(aes(color = salt), size = 2) +
  scale_y_reverse() +
  scale_color_gradientn(colours = fields::tim.colors(16))
ggsave("Figures/06_01_vr51salinity01.png", gg, width = 8.5, height = 5.5)


#
# Interpolation using mba
#
# mba <- mba.surf(df[,c('Time', 'Depth', 'salt')], 100, 50)  # craches RStudio....

#
# 4a. Interpolation using akima (non-linear) ----
#
sel <- complete.cases(df)
sum(sel)
mean(sel)
summary(df$salt[sel])
akima.li <- with(df[sel,], akima::interp(Time, Depth, salt, nx = 100, ny = 100, linear = FALSE)) #, nx = 100, ny = 100))
# image(akima.li$z)
li.zmin <- min(df$salt[sel], na.rm=TRUE)
li.zmax <- max(df$salt[sel], na.rm=TRUE)
breaks <- seq(floor(li.zmin), ceiling(li.zmax), 1)
colors <- fields::tim.colors(length(breaks)-1)
with(akima.li, fields::image.plot(x,y,z, breaks=breaks, col=colors))

#
# 4b. Interpolation using akima, different time scale ----
# Linear and non-linear
# Change scale of time variable (from seconds to days), back-transform before plotting
# Much better result
#
df$Time %>% as.numeric() %>% range() %>% diff()
df$Time2 <- as.numeric(df$Time)/86400
df$Time2 %>% as.numeric() %>% range() %>% diff()

akima.li1 <- with(df[sel,], akima::interp(Time2, Depth, salt, nx = 100, ny = 100, linear = TRUE))    # linear
akima.li2 <- with(df[sel,], akima::interp(Time2, Depth, salt, nx = 100, ny = 100, linear = FALSE))   # spline
# image(akima.li$z)
li.zmin <- min(akima.li2$z,na.rm=TRUE)
li.zmax <- max(akima.li2$z,na.rm=TRUE)
breaks <- seq(floor(li.zmin), ceiling(li.zmax), 1)
colors <- fields::tim.colors(length(breaks)-1)
akima.li1$Time <- as.POSIXct(akima.li1$x*86400, origin = "1970-01-01")
akima.li2$Time <- as.POSIXct(akima.li2$x*86400, origin = "1970-01-01")

png("Figures/06_02_vr51salinity02.png", width = 8.5, height = 5.5, unit = "in", res = 150)
with(akima.li1, fields::image.plot(Time,y,z, breaks=breaks, col=colors))  # looks pretty weird
dev.off()

png("Figures/06_03_vr51salinity03.png", width = 8.5, height = 5.5, unit = "in", res = 150)
with(akima.li2, fields::image.plot(Time,y,z, breaks=breaks, col=colors))  # more like expected
dev.off()


#
# 4c. Same result, plotted using ggplot ----
# See function 
#
dimnames(akima.li2$z)[[2]] <- akima.li2$y

df_plot <- as.data.frame(akima.li2$z) %>%
  data.frame(x = akima.li2$x, .) %>%
  tidyr::gather(key = "y", value = "z", -x) %>%
  mutate(y = as.numeric(sub("X", "", y)),
         Time = as.POSIXct(x*86400, origin = "1970-01-01"))
  
# mean(is.na(df_plot$z))
gg <- ggplot(df_plot, aes(Time, y)) +
  geom_raster(aes(fill = z), interpolate = F, hjust = 0.5, vjust = 0.5) +
  geom_contour(aes(z = z), binwidth = 1) + 
  geom_vline(xintercept = unique(df$Time)) +
  scale_y_reverse() +
  scale_fill_gradientn(colours = fields::tim.colors(16))
ggsave("Figures/06_04_vr51salinity04.png", gg, width = 8.5, height = 5.5)


#
# 4d. Just interpolate - doesn't work well ----
#   (using Time or Time2 - no difference)
#
# mean(is.na(df_plot$z))
gg <- ggplot(df, aes(Time2, Depth)) +
  geom_raster(aes(fill = salt), interpolate = TRUE, hjust = 0.5, vjust = 0.5) +
  geom_contour(aes(z = salt), binwidth = 1) + 
  geom_vline(xintercept = unique(df$Time2)) +
  scale_y_reverse() +
  scale_fill_gradientn(colours = fields::tim.colors(16))
ggsave("Figures/06_05_vr51salinity05.png", gg, width = 8.5, height = 5.5)


dir("K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017")
folder_data <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor1_RMS/ncbase/2018"
dir(folder_data, "*.nc")


#
# 5. Plotting using functions ----
# 

# Compare results with Matlab plots:
# K:\Prosjekter\Sjøvann\KYSTOVERVÅKING ØKOKYST\KYSTOVERVÅKING ØKOKYST 2017-2020\ØKOKYST DP Norskehavet Sør I O-17091_18091_19091\Rapport 2018-data\Vannmassene
#   VR51 + VR71 (Salt, temp, oxy, NO3, PO4, SiO2, plankton biomass and count) 
# K:\Prosjekter\Sjøvann\KYSTOVERVÅKING ØKOKYST\KYSTOVERVÅKING ØKOKYST 2017-2020\ØKOKYST DP Norskehavet Sør II O-17090_19090\Årsrapport2018\2018_Årsrapport\Vannmassene\Plankton
# K:\Prosjekter\Sjøvann\KYSTOVERVÅKING ØKOKYST\KYSTOVERVÅKING ØKOKYST 2017-2020\ØKOKYST DP Skagerrak O-17089_19089\Årsrapport2018\Årsrapport 2018 data\Vannmassene\Plankton
# See mail from: André Staalstrøm <Andre.Staalstrom@niva.no> 
# Sent: fredag 22. februar 2019 08:20


# Function for saving each plot
okokyst_plot_save <- function(fn, var, extra = "", width = 8.5, height = 6.2){
  fn_save <- sprintf("Figures/06_QC/%s_%s%s.png", sub(".nc", "", fn, fixed = TRUE), var, extra)
  ggplot2::ggsave(fn_save, width = 8.5, height = 6.2)  
}

#
# 5a. Norwegian Ocean South 1, VR31 ----
#


folder_data <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor2_SNO/ncbase/2018"
dir(folder_data, "*.nc")
fn <- "VR51_2017_2018.nc"

# Get variable names
ncin <- nc_open(paste0(folder_data, "/", fn))
# str(ncin$var, 1)
names(ncin$var)

# Get variable long names
purrr::transpose(ncin$var)$longname

var <- "salt"
ctd <- TRUE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd)
df_plot <- okokyst_make_plotdata(df, var)  # not actually needed
okokyst_plot(df, var, ctd_variable = ctd, title = fn)
okokyst_plot_save(fn, var)

var <- "temp"
ctd <- TRUE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd)
okokyst_plot_save(fn, var)

var <- "O2sat"
ctd <- TRUE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, binwidth = 20)
okokyst_plot_save(fn, var)

#
# Chl a and nutrients 
#

var <- "NO3"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
ggplot(df, aes(Time, Depth, color = NO3)) + geom_point() + scale_y_reverse()
okokyst_plot(df, var, ctd_variable = ctd, binwidth = 20, limits = c(NA, 250))
okokyst_plot_save(fn, var)

var <- "PO4"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, binwidth = 10, limits = c(NA, 60))
okokyst_plot_save(fn, var)

#
# Phytoplankton cell carbon
#
# $CFYT1 "Diatoms cell carbon"
# $CFYT2 "Dinoflagellates cell carbon"
# $CFYT3  "Other phytoplankton cell carbon"
var <- "CFYT1"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df1 <- df[!is.na(df[,var]),]
var <- "CFYT2"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df2 <- df[!is.na(df[,var]),]
var <- "CFYT3"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df3 <- df[!is.na(df[,var]),]
df <- df1 %>% left_join(df2) %>% left_join(df3)
df %>% 
  tidyr::gather("Taxon", "Cell_carbon", CFYT1:CFYT3) %>%
  ggplot(aes(Time, Cell_carbon, fill = Taxon)) +
  geom_area()
fn_save <- sprintf("Figures/06_QC/%s_%s.png", sub(".nc", "", fn, fixed = TRUE), "planktoncarbon")
ggsave(fn_save)

#
# Phytoplankton counts
#
# $FYT  [1] "Diatoms count"
# $FYT2 [1] "Dinoflagellates count"
# $FYT3 [1] "Other phytoplankton count"

var <- "FYT1"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df1 <- df[!is.na(df[,var]),]
var <- "FYT2"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df2 <- df[!is.na(df[,var]),]
var <- "FYT3"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df3 <- df[!is.na(df[,var]),]
df <- df1 %>% left_join(df2) %>% left_join(df3)
df %>% 
  tidyr::gather("Taxon", "Cell_count", FYT1:FYT3) %>%
  ggplot(aes(Time, Cell_count, fill = Taxon)) +
  geom_area()
fn_save <- sprintf("Figures/06_QC/%s_%s.png", sub(".nc", "", fn, fixed = TRUE), "planktoncounts")
ggsave(fn_save)




#
# 5b. Norwegion Ocean South 1, VT71_2013_2018 ----
#

dir(folder_data, "*.nc")
fn <- "VT71_2013_2018.nc"

# Get variable names
ncin <- nc_open(paste0(folder_data, "/", fn))
# str(ncin$var, 1)
names(ncin$var)

# Get variable long names
purrr::transpose(ncin$var)$longname

var <- "salt"
ctd <- TRUE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd)
okokyst_plot(df, var, ctd_variable = ctd, color_ctdtime = "grey70")
okokyst_plot_save(fn, var)


var <- "temp"
ctd <- TRUE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, color_ctdtime = "grey80")
okokyst_plot_save(fn, var)

var <- "O2sat"
ctd <- TRUE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, binwidth = 20, color_ctdtime = "grey80")
okokyst_plot_save(fn, var)

#
# Same station, chl a and nutrients
#
var <- "KlfA"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df_plot <- okokyst_make_plotdata(df, var)
okokyst_plot(df, var, ctd_variable = ctd)
okokyst_plot_save(fn, var)

var <- "NO3"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, binwidth = 20, limits = c(NA, 250))
okokyst_plot_save(fn, var)

var <- "PO4"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, binwidth = 5)
okokyst_plot_save(fn, var)

var <- "SiO2"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, binwidth = 20)
okokyst_plot_save(fn, var)

#
# Phytoplankton cell carbon
#
# $CFYT1 "Diatoms cell carbon"
# $CFYT2 "Dinoflagellates cell carbon"
# $CFYT3  "Other phytoplankton cell carbon"
var <- "CFYT1"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df1 <- df[!is.na(df[,var]),]
var <- "CFYT2"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df2 <- df[!is.na(df[,var]),]
var <- "CFYT3"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df3 <- df[!is.na(df[,var]),]
df <- df1 %>% left_join(df2) %>% left_join(df3)
df %>% 
  tidyr::gather("Taxon", "Cell_carbon", CFYT1:CFYT3) %>%
  ggplot(aes(Time, Cell_carbon, fill = Taxon)) +
  geom_area()
fn_save <- sprintf("Figures/06_QC/%s_%s.png", sub(".nc", "", fn, fixed = TRUE), "planktoncarbon")
ggsave(fn_save)

#
# Phytoplankton counts
#
# $FYT  [1] "Diatoms count"
# $FYT2 [1] "Dinoflagellates count"
# $FYT3 [1] "Other phytoplankton count"

var <- "FYT1"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df1 <- df[!is.na(df[,var]),]
var <- "FYT2"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df2 <- df[!is.na(df[,var]),]
var <- "FYT3"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df3 <- df[!is.na(df[,var]),]
df <- df1 %>% left_join(df2) %>% left_join(df3)
df %>% 
  tidyr::gather("Taxon", "Cell_count", FYT1:FYT3) %>%
  ggplot(aes(Time, Cell_count, fill = Taxon)) +
  geom_area()
fn_save <- sprintf("Figures/06_QC/%s_%s.png", sub(".nc", "", fn, fixed = TRUE), "planktoncounts")
ggsave(fn_save)


#
# 5c. Norwegion Ocean South 2, VR31 ----
#

dir("K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor2_SNO/ncbase/2018")            # VR31_2014_2018
dir("K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor2_Aquakompetanse/ncbase/2018") # VR52_2017_2018
dir("K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor2_MagneAuren/ncbase/2018")     # VT42_2011_2018


folder_data <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor2_SNO/ncbase/2018"
dir(folder_data, "*.nc")
fn <- "VR31_2014_2018.nc"

# Get variable names
ncin <- nc_open(paste0(folder_data, "/", fn))
# str(ncin$var, 1)
names(ncin$var)

# Get variable long names
purrr::transpose(ncin$var)$longname

var <- "salt"
ctd <- TRUE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd)
okokyst_plot(df, var, ctd_variable = ctd, title = fn, color_ctdtime = "grey70")
okokyst_plot_save(fn, var)


var <- "temp"
ctd <- TRUE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, title = fn, color_ctdtime = "grey80")
okokyst_plot_save(fn, var)

var <- "O2sat"
ctd <- TRUE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, title = fn, binwidth = 20, color_ctdtime = "grey80")
okokyst_plot_save(fn, var)

#
# Same station, chl a and nutrients
#

var <- "NO3"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, title = fn, binwidth = 20, limits = c(0, 250))
okokyst_plot_save(fn, var)
okokyst_plot_points(df, var, ctd_variable = ctd, title = fn, limits = c(0, 250))
okokyst_plot_save(fn, var, extra = "_02")

var <- "PO4"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, title = fn, binwidth = 10, limits = c(0, 60))
okokyst_plot_save(fn, var)
okokyst_plot_points(df, var, ctd_variable = ctd, title = fn, limits = c(0, 60))
okokyst_plot_save(fn, var, extra = "_02")


#
# Phytoplankton cell carbon
#
# $CFYT1 "Diatoms cell carbon"
# $CFYT2 "Dinoflagellates cell carbon"
# $CFYT3  "Other phytoplankton cell carbon"
var <- "CFYT1"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df1 <- df[!is.na(df[,var]),]
var <- "CFYT2"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df2 <- df[!is.na(df[,var]),]
var <- "CFYT3"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df3 <- df[!is.na(df[,var]),]
df <- df1 %>% left_join(df2) %>% left_join(df3)
df %>% 
  tidyr::gather("Taxon", "Cell_carbon", CFYT1:CFYT3) %>%
  ggplot(aes(Time, Cell_carbon, fill = Taxon)) +
  geom_area()
fn_save <- sprintf("Figures/06_QC/%s_%s.png", sub(".nc", "", fn, fixed = TRUE), "planktoncarbon")
ggsave(fn_save)

#
# Phytoplankton counts
#
# $FYT  [1] "Diatoms count"
# $FYT2 [1] "Dinoflagellates count"
# $FYT3 [1] "Other phytoplankton count"

var <- "FYT1"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df1 <- df[!is.na(df[,var]),]
var <- "FYT2"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df2 <- df[!is.na(df[,var]),]
var <- "FYT3"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df3 <- df[!is.na(df[,var]),]
df <- df1 %>% left_join(df2) %>% left_join(df3)
df %>% 
  tidyr::gather("Taxon", "Cell_count", FYT1:FYT3) %>%
  ggplot(aes(Time, Cell_count, fill = Taxon)) +
  geom_area()
fn_save <- sprintf("Figures/06_QC/%s_%s.png", sub(".nc", "", fn, fixed = TRUE), "planktoncounts")
ggsave(fn_save)



#
# 5d. Norwegion Ocean South 2, VR42 ----
#

dir("K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor2_SNO/ncbase/2018")            # VR31_2014_2018
dir("K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor2_Aquakompetanse/ncbase/2018") # VR52_2017_2018
dir("K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor2_MagneAuren/ncbase/2018")     # VT42_2011_2018


folder_data <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor2_MagneAuren/ncbase/2018"
dir(folder_data, "*.nc")
fn <- "VT42_2011_2018.nc"
# fn <- dir(folder_data, "*.nc")[1]

# Get variable names
ncin <- nc_open(paste0(folder_data, "/", fn))
# str(ncin$var, 1)
names(ncin$var)

# Get variable long names
purrr::transpose(ncin$var)$longname

var <- "salt"
ctd <- TRUE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd, folder_data = folder_data)
okokyst_plot(df, var, ctd_variable = ctd, title = fn, color_ctdtime = "grey70")
okokyst_plot_save(fn, var)


var <- "temp"
ctd <- TRUE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, title = fn, color_ctdtime = "grey80")
okokyst_plot_save(fn, var)

var <- "O2sat"
ctd <- TRUE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, title = fn, binwidth = 20, color_ctdtime = "grey80")
okokyst_plot_save(fn, var)

#
# Same station, chl a and nutrients
#

var <- "NO3"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, title = fn, binwidth = 20, limits = c(0, 250))
okokyst_plot_save(fn, var)
okokyst_plot_points(df, var, ctd_variable = ctd, title = fn, limits = c(0, 250))
okokyst_plot_save(fn, var, extra = "_02")

var <- "PO4"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
okokyst_plot(df, var, ctd_variable = ctd, title = fn, binwidth = 10, limits = c(0, 60))
okokyst_plot_save(fn, var)
okokyst_plot_points(df, var, ctd_variable = ctd, title = fn, limits = c(0, 60))
okokyst_plot_save(fn, var, extra = "_02")


#
# Phytoplankton cell carbon
#
# $CFYT1 "Diatoms cell carbon"
# $CFYT2 "Dinoflagellates cell carbon"
# $CFYT3  "Other phytoplankton cell carbon"
var <- "CFYT1"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df1 <- df[!is.na(df[,var]),]
var <- "CFYT2"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df2 <- df[!is.na(df[,var]),]
var <- "CFYT3"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df3 <- df[!is.na(df[,var]),]
df <- df1 %>% left_join(df2) %>% left_join(df3)
df %>% 
  tidyr::gather("Taxon", "Cell_carbon", CFYT1:CFYT3) %>%
  ggplot(aes(Time, Cell_carbon, fill = Taxon)) +
  geom_area()
fn_save <- sprintf("Figures/06_QC/%s_%s.png", sub(".nc", "", fn, fixed = TRUE), "planktoncarbon")
ggsave(fn_save)

#
# Phytoplankton counts
#
# $FYT  [1] "Diatoms count"
# $FYT2 [1] "Dinoflagellates count"
# $FYT3 [1] "Other phytoplankton count"

var <- "FYT1"
ctd <- FALSE
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df1 <- df[!is.na(df[,var]),]
var <- "FYT2"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df2 <- df[!is.na(df[,var]),]
var <- "FYT3"
df <- okokyst_read_nc(fn, var, ctd_variable = ctd); mean(!is.na(df[[var]]))
df3 <- df[!is.na(df[,var]),]
df <- df1 %>% left_join(df2) %>% left_join(df3)
df %>% 
  tidyr::gather("Taxon", "Cell_count", FYT1:FYT3) %>%
  ggplot(aes(Time, Cell_count, fill = Taxon)) +
  geom_area()
fn_save <- sprintf("Figures/06_QC/%s_%s.png", sub(".nc", "", fn, fixed = TRUE), "planktoncounts")
ggsave(fn_save)


