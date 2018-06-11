
library(ncdf4)

#
# Read one variable from one okokyst file
# Set 'ctd_variable' = TRUE if the variable is a CTD variable (values for every 1 m) such as temp, salinity
# Set 'ctd_variable' = FALSE if the variable is a water sample variable (values for 0,5,10,20 ..m) such as 
#   chlorophyll, nutrients
#
# Examples:
#   df <- okokyst_read_nc("VR51.nc", "salt", ctd_variable = TRUE)
#   df <- okokyst_read_nc("VR51.nc", "KlfA", ctd_variable = FALSE)
#
okokyst_read_nc <- function(fn, variable, ctd_variable, report = FALSE, 
                            folder_data = "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/ncbase_OKOKYST"){
  if (report)
    cat(fn, variable, "\n")
  ncin <- nc_open(paste0(folder_data, "/", fn))
  lon <- ncvar_get(ncin,"lon")
  lat <- ncvar_get(ncin,"lat")
  time <- ncvar_get(ncin, "time")
  time <- as.POSIXct(time + 1, tz = "UTC", origin = "1970-01-01")   # add 1 second in order to get a time, not  date
  depth <- ncvar_get(ncin, "depth")
  depth_nut <- ncvar_get(ncin, "depth_nut")
  Y <- ncvar_get(ncin, variable)
  nc_close(ncin)
  # Pick depth variable depending on whether we hav a CTD variable or a water sample variable
  if (ctd_variable){
    df <- data.frame(Depth = depth, Y)
  } else {
    df <- data.frame(Depth = depth_nut, Y)
  }
  # Set column names to equal time. Must add t_ in front in order to be "legal" column names
  colnames(df)[-1] <- paste0("t_", time)
  # Rearrange data from wide to tall, so time becomes a variable
  df2 <- tidyr::gather(df, "Time", "Y", -Depth)
  df2$Time <- lubridate::ymd_hms(sub("t_","",df2$Time))  # Change time variable from character to time 
  colnames(df2)[3] <- variable
  # Add name of file, longitude and latitude
  df2 <- data.frame(Filename = fn, Long = lon, Lat = lat, df2, stringsAsFactors = FALSE)
  if (report){
    cat("\n")
    print(df2[1:3,])
    cat("\n")
    }
  df2
  }



