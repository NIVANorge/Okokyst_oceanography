# From: André Staalstrøm <Andre.Staalstrom@niva.no> 
#   Sent: mandag 25. februar 2019 13.41
# To: Dag Øystein Hjermann <Dag.Hjermann@niva.no>
#   Subject: R-hjelp til NIVAklass
# 
# Hei Dag
# 
# Jeg lurte på om du kunne hjelpe til litt med å regne statistikk for klassifisering av Økokyst stasjonene.
# Dvs. hvis du hjelper meg med en stasjon så kan jeg gjøre resten.
# 
# Jeg har startet med stasjon VR31 hvor det er data fra 2014-2018. Alt ligger her:
#   K:\Prosjekter\Sjøvann\KYSTOVERVÅKING ØKOKYST\KYSTOVERVÅKING ØKOKYST 2017-2020\ØKOKYST DP Norskehavet Sør II O-17090_19090\Årsrapport2018\2018_Årsrapport\Vannmassene\NIVAclass
# 
# Jeg har et matlab script som leser data fra en NetCDF fil, og skriver data rett inn i selve NIVAklass excel fila. I tillegg skrives det til en ekstra excel fil med statistikk for hvert år.
# 
# Jeg har startet på et R script, men trenger hjelp til å fullføre, slik at det gjør det samme som matlab scriptet.
# 
# Si fra om du kan hjelpe til med dette. Eventuelt så kan jeg spørre noen av de andre R folka på NIVA.
# 
# Fordelen med R er at en kan velge metode for 90 persentilen, som i følge veileder 02:2018 s. 139, skal gi samme resultat som funksjonen «Persentile.inc» i Excel.
# 
# mvh Andre

# See "NIVAklass_VR31.m" in folder Excel_files



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

# Check folder names
dir("K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017")            # VR31_2014_2018

# Define folder
folder_data <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor2_SNO/ncbase/2018"

# Check file names
dir(folder_data, "*.nc")

# Define file name and station name
fn <- "VR31_2014_2018.nc"
name='Tilremsfjorden'

# Extract station code from file name
code <- stringr::str_extract(fn, "^[^_]+(?=_)")

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#  Read station data and depth ----
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

# station data
lon = ncvar_get(ncin,"lon")
lat = ncvar_get(ncin,"lat")

# Print station info
cat(code, ": ", name, " N", lat, " E", lon, sep = "")

# Depths
z     <- ncin$dim$depth$vals
z_nut <- ncin$dim$depth_nut$vals


# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
# Check file info ----
# If necessary
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

# names(ncin$var)                       # Show variable names
# purrr::transpose(ncin$var)$longname   # Show variable long names
# str(ncin, 1)                          # Show file contents

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#  Oxygen in the deep water ----
#  Use data from 250 m
#  Tviler litt på konsentrasjonen siden O2vol fra 2017 så rare (lave) ut
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

# Get oxygen data
O2sat <- okokyst_read_nc(fn, "O2sat", ctd_variable = TRUE)
O2vol <- okokyst_read_nc(fn, "O2vol", ctd_variable = TRUE)
O2sat_sample <- okokyst_read_nc(fn, "O2sat_sample", ctd_variable = FALSE)
O2vol_sample <- okokyst_read_nc(fn, "O2vol_sample", ctd_variable = FALSE)

# Get oxygen data from bottom layer; add Year val
O2dyp <- max(z_nut);
O2sat_bunn = subset(O2sat_sample, Depth %in% O2dyp)
O2vol_bunn = subset(O2vol_sample, Depth %in% O2dyp)

# Test plot (if you have cowplot installed, you can combine plots into one plot)

# If you want to install cowplot:
# install.packages("cowplot")

cowplot::plot_grid(
  ggplot(O2sat_bunn, aes(Time, O2sat_sample)) + geom_line() + geom_point(),
  ggplot(O2vol_bunn, aes(Time, O2vol_sample)) + geom_line() + geom_point(),
  ncol = 1)

# Annual minimum values ('na.rm = TRUE' means that NAs are ignored)
data_O2sat_year <- O2sat_bunn %>%
  mutate(Year = year(Time)) %>%
  group_by(Year) %>%
  summarize(Value = min(O2sat_sample, na.rm = TRUE))

data_O2vol_year <- O2vol_bunn %>%
  mutate(Year = year(Time)) %>%
  group_by(Year) %>%
  summarize(Value = min(O2vol_sample, na.rm = TRUE))

# for n=1:NY
# nget=find(year==YY(n));
# uO2(n)=min(O2vol_bunn(nget));  % Mulig feil enhet 2017
# uOS(n)=min(O2sat_bunn(nget));
# end
# uO2(YY==2017) = NaN;

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==
#  Nutrients ----
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==
#  Calculate average for 0-15m
#  Each depth is weighted differently
#  Data from 0, 5, 10 and 20 is used
#  Formula:
# 
#  C(0-15) = (2/12)*C0 + (4/12)*C5 + (5/12)*C10 + (1/12)*C20
# 
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==


# Weights (will be used for weighted average)
weights_nut <- data.frame(
  Depth = c(0, 5, 10, 20),
  Weight = c(2/12, 4/12, 5/12, 1/12)
)

# Read data, add weights (will be used for weighted average), and keep only 0-20 m data (remove Weight = NA)
TP   <- okokyst_read_nc(fn, "TotP", ctd_variable = FALSE) %>%
  left_join(weights_nut, by = "Depth") %>% filter(!is.na(Weight)) 
PO4  <- okokyst_read_nc(fn, "PO4", ctd_variable = FALSE) %>%
  left_join(weights_nut, by = "Depth") %>% filter(!is.na(Weight))
TN   <- okokyst_read_nc(fn, "TotN", ctd_variable = FALSE) %>%
  left_join(weights_nut, by = "Depth") %>% filter(!is.na(Weight))
NO3  <- okokyst_read_nc(fn, "NO3", ctd_variable = FALSE) %>%
  left_join(weights_nut, by = "Depth") %>% filter(!is.na(Weight))
NH4  <- okokyst_read_nc(fn, "NH4", ctd_variable = FALSE) %>%
  left_join(weights_nut, by = "Depth") %>% filter(!is.na(Weight))
SiO2 <- okokyst_read_nc(fn, "SiO2", ctd_variable = FALSE) %>%
  left_join(weights_nut, by = "Depth") %>% filter(!is.na(Weight))


# Weighted average over depths, per sampling occasion
# Also add column 'Variable' so data can be combined later ('bind_rows')
uTP   <- TP %>% group_by(Time) %>% summarize(Average = sum(TotP*Weight)) %>% mutate(Variable = "TP")
uPO4  <- PO4 %>% group_by(Time) %>% summarize(Average = sum(PO4*Weight)) %>% mutate(Variable = "PO4")
uTN   <- TN %>% group_by(Time) %>% summarize(Average = sum(TotN*Weight)) %>% mutate(Variable = "TN")
uNO3  <- NO3 %>% group_by(Time) %>% summarize(Average = sum(NO3*Weight)) %>% mutate(Variable = "NO3")
uNH4  <- NH4 %>% group_by(Time) %>% summarize(Average = sum(NH4*Weight)) %>% mutate(Variable = "NH4")
uSiO2 <- SiO2 %>% group_by(Time) %>% summarize(Average = sum(SiO2*Weight)) %>% mutate(Variable = "SiO2")

# Secchi depth, treated by itself (raw data is already one value per sampling occasion)
usikt <- data.frame(
  Time = as.POSIXct(ncvar_get(ncin, "time") + 1, tz = "UTC", origin = "1970-01-01"),
  Average = ncvar_get(ncin,"secchi"),
  Variable = "Sikt",
  stringsAsFactors = FALSE
)

# Plots for sanity check (plot one by one)
ggplot(TP, aes(Time, TotP, color = factor(Depth))) + geom_line() + geom_point() +
  geom_line(data = uTP, aes(y = Average), color = "black", size = 1)
ggplot(PO4, aes(Time, PO4, color = factor(Depth))) + geom_line() + geom_point() +
  geom_line(data = uPO4, aes(y = Average), color = "black", size = 1)
ggplot(TN, aes(Time, TotN, color = factor(Depth))) + geom_line() + geom_point() +
  geom_line(data = uTN, aes(y = Average), color = "black", size = 1)
ggplot(PO4, aes(Time, PO4, color = factor(Depth))) + geom_line() + geom_point() +
  geom_line(data = uPO4, aes(y = Average), color = "black", size = 1)
ggplot(NH4, aes(Time, NH4, color = factor(Depth))) + geom_line() + geom_point() +
  geom_line(data = uNH4, aes(y = Average), color = "black", size = 1)
ggplot(SiO2, aes(Time, SiO2, color = factor(Depth))) + geom_line() + geom_point() +
  geom_line(data = uSiO2, aes(y = Average), color = "black", size = 1)

# Combine data and add time variables
data_nutrients <- bind_rows(usikt, uTP, uPO4, uTN, uNO3, uNH4, uSiO2) %>%
  mutate(Year = year(Time),
         Month = month(Time),
         Measurement_year = ifelse(Month %in% 1:2, Year - 1, Year),
         Season = case_when(
           Month %in% 3:5 ~ "Spring",
           Month %in% 6:8 ~ "Summer",
           Month %in% 9:11 ~ "Autumn",
           Month %in% c(12,1,2) ~ "Winter"
         ))

# Annual average per season
data_nutrients_season <- data_nutrients %>%
  group_by(Variable, Measurement_year, Season) %>%
  summarize(Season_average = mean(Average, na.rm = TRUE)) %>%
  ungroup()



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


# Weights (will be used for weighted average)
weights_chla <- data.frame(
  Depth = c(0, 5, 10),
  Weight = c(1/4, 2/4, 1/4)
)

# Read data, add weights (will be used for weighted average), and keep only 0-10 m data (remove Weight = NA)
KlfA <- okokyst_read_nc(fn, "KlfA", ctd_variable = FALSE) %>%
  left_join(weights_chla, by = "Depth") %>% filter(!is.na(Weight)) 

# Weighted average over depths, per sampling occasion
uKlfA   <- KlfA %>% 
  group_by(Time) %>% 
  summarize(Average = sum(KlfA*Weight)) %>%
  mutate(Year = year(Time), 
         Month = month(Time)
         )

# Plot for sanity check 
ggplot(KlfA, aes(Time, KlfA, color = factor(Depth))) + geom_line() + geom_point() +
  geom_line(data = uKlfA, aes(y = Average), color = "black", size = 1)


# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==
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
# Run ?quantile for description of types

if (lat > 62){
  data_klfa_year <- uKlfA %>%
    filter(Month %in% 3:9) %>%   # Mars til Spetember, se s. 138 i Veileder 02:2018
    group_by(Year) %>%
    summarize(Value = quantile(Average, 0.9, type = percentile_type))
} else {
  data_klfa_year <- uKlfA %>%
    filter(Month %in% 2:10) %>%
    group_by(Year) %>%
    summarize(Value = quantile(Average, 0.9, type = percentile_type))
}

# Another plot for sanity check
ggplot(KlfA, aes(Time, KlfA, color = factor(Depth))) + geom_line() + geom_point() +
  geom_line(data = uKlfA, aes(y = Average), color = "black", size = 1) +
  geom_point(data = data_klfa_year, aes(x = ymd_hms(paste(Year, "07 01 00:00:00")), y = Value), size = 3, color = "red")

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#  Combine all year-wise stats ----
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

# Oxygen
df1 <- bind_rows(data_O2sat_year %>% mutate(Variable = "O2sat_min"),
                 data_O2vol_year %>% mutate(Variable = "O2vol_min")
                 )

# Nutrients
df2 <- data_nutrients_season %>%
  filter(Season %in% c("Summer", "Winter")) %>%
  mutate(Variable = ifelse(Season == "Summer", paste0(Variable, "_sum"), paste0(Variable, "_win"))) %>%
  rename(Year = Measurement_year, Value = Season_average) %>%
  select(Variable, Year, Value)

# Chl a
df3 <- data_klfa_year %>% mutate(Variable = "KlfA_p90") %>% rename
  
all_statistics <- bind_rows(df1, df2, df3)

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#  Write stats for each year to Excel ----
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

vars <- c("Year", "Sikt_sum", "KlfA_p90", 
          "TP_sum", "PO4_sum", "TN_sum", "NO3_sum", "NH4_sum", "SiO2_sum",
          "TP_win", "PO4_win", "TN_win", "NO3_win", "NH4_win", "SiO2_win",
          "O2sat_min", "O2vol_min")

data_for_summary_file <- all_statistics %>%
  filter(Year >= 2014) %>%
  mutate(Value = round(Value, 2), 
         Value = ifelse(is.nan(Value), NA, Value)) %>%
  spread(Variable, Value) %>% # colnames() %>% dput() 
  select(vars) %>%
  rename(Sikt = Sikt_sum) 

write.xlsx(data_for_summary_file, sprintf("Excel_files/%s_stats.xlsx", code))

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#  Stats for the whole period ----
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o

# Annual minimum values ('na.rm = TRUE' means that NAs are ignored)
data_O2sat_overall <- O2sat_bunn %>%
  summarize(Value = min(O2sat_sample, na.rm = TRUE))

data_O2vol_overall <- O2vol_bunn %>%
  summarize(Value = min(O2vol_sample, na.rm = TRUE))

# Average per season
data_nutrients_season_overall <- data_nutrients %>%
  group_by(Variable, Season) %>%
  summarize(Season_average = mean(Average, na.rm = TRUE)) %>%
  ungroup()


# Average per season
if (lat > 62){
  data_klfa_overall <- uKlfA %>%
    filter(Month %in% 3:9) %>%   # Mars til Spetember, se s. 138 i Veileder 02:2018
    summarize(Value = quantile(Average, 0.9, type = percentile_type))
} else {
  data_klfa_overall <- uKlfA %>%
    filter(Month %in% 2:10) %>%
    summarize(Value = quantile(Average, 0.9, type = percentile_type))
}


# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
# Write to NIVAklass Excel file ----
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o


# Note: package xlsx doesn't work using the xltx file. File can be read but not opened by Excel later
# Solution: The template must be saved as an xlsx file first
file <- "Excel_files/NIVAklass_kystvann.xltx"      # doesn't work
file <- "C:/Data/temp/NIVAklass_kystvann1.xlsx"    # does work
# "C:\Data\temp\NIVAklass_kystvann1.xlsx"
wb <- loadWorkbook(file)
sheets <- getSheets(wb)
sheet <- sheets[["Klassifisering"]] # extract the second sheet
sheet$getLastRowNum()
rows <- getRows(sheet) # get all the rows
cells <- getCells(rows) # returns all non empty cells
getCellValue(cells[["3.1"]])
getCellValue(cells[["24.2"]])
getCellValue(cells[["24.4"]])         # = D24
setCellValue(cells[["24.4"]], 2.45)   # Set D24 cell
getCellValue(cells[["24.4"]])         # Check again
saveWorkbook(wb, "Excel_files/test5.xlsx")


% Write station data to xls
disp('Writing to NIVAklass...')
xlswrite(xls,cellstr(name),'Klassifisering','C4');
xlswrite(xls,cellstr(code),'Klassifisering','F4');
xlswrite(xls,lat,'Klassifisering','C6');
xlswrite(xls,lon,'Klassifisering','C7');
% Write stat results to xls
xlswrite(xls,KlfA_P90,'Klassifisering','D24');

xlswrite(xls,TP_sum,   'Klassifisering','D120');
xlswrite(xls,PO4_sum,  'Klassifisering','D121');
xlswrite(xls,TN_sum,   'Klassifisering','D122');
xlswrite(xls,NO3_sum,  'Klassifisering','D123');
xlswrite(xls,NH4_sum,  'Klassifisering','D124');
xlswrite(xls,sikt_mean,'Klassifisering','D125');

xlswrite(xls,TP_win,   'Klassifisering','D128');
xlswrite(xls,PO4_win,  'Klassifisering','D129');
xlswrite(xls,TN_win,   'Klassifisering','D130');
xlswrite(xls,NO3_win,  'Klassifisering','D131');
xlswrite(xls,NH4_win,  'Klassifisering','D132');

xlswrite(xls,O2_min,   'Klassifisering','D135');
xlswrite(xls,OS_min,   'Klassifisering','D136');


# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==
# APPENDIX 1: check types of percentiles ----
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==

# Percentile types using >10 numbers:
perc90 <- 1:9 %>% purrr::map_dbl(~quantile(1:18, 0.9, type=.))   # 0.9 percentile of numbers 1-18 using type 1-9
data.frame(Type = 1:9, perc90)
# Percentile types using <10 numbers:
# Note that for type 6, 90% quantile = max!
perc90 <- 1:9 %>% purrr::map_dbl(~quantile(1:7, 0.9, type=.))   # 0.9 percentile of numbers 1-18 using type 1-9
data.frame(Type = 1:9, perc90)

# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==
# APPENDIX 2: check percentiles of example in veileder ----
# Veileder 02:2013: Klassifisering av miljøtilstand i vann
# =o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o==

example <- read.table("Excel_files/veileder_eksempel_side_216.txt", dec = ",", header = FALSE)
colnames(example) <- c("Date", "Depth", "KlfA")
example$Date <- dmy(example$Date)
klfa <- example %>%
  filter(month(Date) %in% 2:10) %>%
  pull(KlfA)
perc90 <- 1:9 %>% purrr::map_dbl(~quantile(klfa, 0.9, type=.))   # 0.9 percentile of numbers 1-18 using type 1-9
tibble(Type = 1:9, perc90)
