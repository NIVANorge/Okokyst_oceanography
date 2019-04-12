
library(ncdf4)

#
# Read one variable from one okokyst file
# - Used in script 02 and 08 (at least)
# Set 'ctd_variable' = TRUE if the variable is a CTD variable (values for every 1 m) such as temp, salinity
# Set 'ctd_variable' = FALSE if the variable is a water sample variable (values for 0,5,10,20 ..m) such as 
#   chlorophyll, nutrients
#
# Examples:
#   df <- okokyst_read_nc("VR51.nc", "salt", ctd_variable = TRUE)
#   df <- okokyst_read_nc("VR51.nc", "KlfA", ctd_variable = FALSE)
#
okokyst_read_nc <- function(fn, variable, ctd_variable, report = FALSE, 
                            folder_data = "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/ncbase_OKOKYST",
                            read_depth_nut = TRUE){
  if (report)
    cat(fn, variable, "\n")
  ncin <- nc_open(paste0(folder_data, "/", fn))
  lon <- ncvar_get(ncin,"lon")
  lat <- ncvar_get(ncin,"lat")
  time <- ncvar_get(ncin, "time")
  time <- as.POSIXct(time + 1, tz = "UTC", origin = "1970-01-01")   # add 1 second in order to get a time, not  date
  depth <- ncvar_get(ncin, "depth")
  if (read_depth_nut)
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


#
# Like okokyst_read_nc but automatically finds dimension (i.e. 'ctd_variable' and 'read_depth_nut' is superfluous)
# - Used in script 09
# Also able to read variables without depth, such as Secchi depth (Depth is set to NA)
# Also: 
# - returns data in tidy format: one column 'Variable' has variable name and unit
# - another column is named Value and has the actual data
#

okokyst_read_nc2 <- function(fn, variable, report = FALSE, 
                            folder_data = "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/ncbase_OKOKYST"){
  if (report)
    cat(fn, variable, "\n")
  ncin <- nc_open(paste0(folder_data, "/", fn))
  lon <- ncvar_get(ncin,"lon")
  lat <- ncvar_get(ncin,"lat")
  ProjectId <- ncvar_get(ncin,"ProjectId")
  StationId <- ncvar_get(ncin,"StationId")
  time <- ncvar_get(ncin, "time")
  time <- as.POSIXct(time + 1, tz = "UTC", origin = "1970-01-01")   # add 1 second in order to get a time, not  date
  ndim <- length(ncin$var[[variable]]$dim)
  dim1 <- ncin$var[[variable]]$dim[[1]]$name
  units <- ncin$var[[variable]]$units
  if (dim1 != "time"){
    depth <- ncvar_get(ncin, dim1)
    value <- ncvar_get(ncin, variable)
    nc_close(ncin)
    df <- data.frame(Depth = depth, Value = value)
    # Set column names to equal time. Must add t_ in front in order to be "legal" column names
    colnames(df)[-1] <- paste0("t_", time)
    # Rearrange data from wide to tall, so time becomes a variable
    df2 <- tidyr::gather(df, "Time", "Value", -Depth)
    df2$Time <- lubridate::ymd_hms(sub("t_","",df2$Time))  # Change time variable from character to time 
  } else {
    time <- ncvar_get(ncin, dim1)
    value <- ncvar_get(ncin, variable)
    nc_close(ncin)
    df2 <- data.frame(Depth = NA, Time = time, Value = value)
    df2$Time <- as.POSIXct(df2$Time, origin = "1970-01-01", tz = "GMT")  # time variable:from number (UNIX time) to time
  }
  df2 <- data.frame(Variable = paste0(variable, "_", units), df2, stringsAsFactors = FALSE)
  # Add name of file, longitude and latitude
  df2 <- data.frame(Filename = fn, Long = lon, Lat = lat, ProjectId = ProjectId, StationId = StationId, 
                    df2, 
                    stringsAsFactors = FALSE)
  if (variable %in% "time_nut"){
    df2$Variable <- "time_nut_unix"
    # df2$Value <- as.POSIXct(df2$Value, origin = "1970-01-01", tz = "GMT")
  }
  if (report){
    cat("\n")
    print(df2[1:3,])
    cat("\n")
  }
  df2
}

# Test
# fn <- "Glomfjord_data/ncbase_Glomfjord/Gl-1_2017.nc"
# datafolder <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017"
# df1 <- okokyst_read_nc2(fn, "salt", folder_data = datafolder)       # a CTD variable (data every meter depth)
# df2 <- okokyst_read_nc2(fn, "TotP", folder_data = datafolder)       # a nutrient variable (4 dephts)
# df3 <- okokyst_read_nc2(fn, "secchi", folder_data = datafolder)     # a variable without depth (time only)


#
# This uses 'okokyst_read_nc2' to read all variables in a file
# Data are in tidy format so they are "stacked" inside the function
#
okokyst_readall_nc <- function(fn, report = FALSE, 
                               folder_data = "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/ncbase_OKOKYST"){
  ncin <- nc_open(paste0(folder_data, "/", fn))
  if (report)
    cat("File", fn, "is opened\n")
  var_names <- names(ncin$var)   # Get all variable names
  nc_close(ncin)
  var_names <- var_names[!var_names %in% c("depth1", "depth2", "lat", "lon", "ProjectId", "StationId")]
  for (var in var_names){
    if (report)
      cat("", var)
    df <- okokyst_read_nc2(fn, var, folder_data = folder_data)
    if (var == var_names[1]){
      df_collected <- df
    } else {
      df_collected <- bind_rows(df_collected, df)
    }
  }
  if (report)
    cat("\n")
  df_collected
}

# fn <- "Glomfjord_data/ncbase_Glomfjord/Gl-1_2017.nc"
# datafolder <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017"
# df <- okokyst_readall_nc(fn, folder_data = datafolder, report = TRUE)       # a CTD variable (data every meter depth)


#
# Make ggplot-ready data (including interpolation)
#
okokyst_make_plotdata <- function(data, varname){
  data <- as.data.frame(data)
  sel <- complete.cases(data[,c("Time", "Depth", varname)])
  data <- dplyr::rename(data, "z" = varname)
  # Interpolation
  data$Time2 <- as.numeric(data$Time)/86400    # convert to day-scale, for better interpolation
  interpol <- with(data[sel,], akima::interp(Time2, Depth, z, nx = 100, ny = 100, linear = FALSE))   # spline
  # Reshaping data
  dimnames(interpol$z)[[2]] <- interpol$y
  as.data.frame(interpol$z) %>%
    data.frame(x = interpol$x, .) %>%
    tidyr::gather(key = "y", value = "z", -x) %>%
    mutate(Depth = as.numeric(sub("X", "", y)),
           Time = as.POSIXct(x*86400, origin = "1970-01-01")) %>%
    select(-y)
  }

# df_plot <- okokyst_make_plotdata(df, "salt")

okokyst_plot <- function(data, varname, ctd_variable, title = "", binwidth = 1, limits = c(NA,NA),
                         color_ctdtime = "black"){
  df_plot <- okokyst_make_plotdata(data, varname)
  gg <- ggplot(df_plot, aes(Time, Depth)) +
    geom_raster(aes(fill = z), interpolate = F, hjust = 0.5, vjust = 0.5) +
    geom_contour(aes(z = z), binwidth = binwidth) + 
    scale_y_reverse() +
    scale_fill_gradientn(varname, colours = fields::tim.colors(16), limits = limits)
  if (ctd_variable){
    gg <- gg + geom_vline(xintercept = unique(data$Time), color = color_ctdtime)
  } else {
    gg <- gg + geom_point(data = data, aes(Time, Depth), color = "white", size = 0.5)
  }
  if (title != "")
    gg <- gg + ggtitle(title)
  gg
}

okokyst_plot_points <- function(data, varname, ctd_variable, title = "", binwidth = 1, limits = c(NA,NA),
                         color_ctdtime = "black"){
  df_plot <- data %>% rename("z" = varname)
  gg <- ggplot(df_plot, aes(Time, Depth)) +
    geom_point(aes(color = z)) +
    scale_y_reverse() +
    scale_color_gradientn(varname, colours = fields::tim.colors(16), limits = limits)
  if (title != "")
    gg <- gg + ggtitle(title)
  gg
}

