
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
# data:     Data on "long" format. Variables must be "Depth" and "Time"
# varname:  Name of variable to plot (quoted string)
# gam:      Uses mgcv:gam if gam = TRUE, otherwise uses akima. Default is gam = FALSE
# gam_k:    The "k" (degrees of freedom + 1) for mgcv:gam. Ignored if gam = FALSE
# linear:   TRUE/FALSE depending on whether you will use a linear akima interpolation or not. Ignored if gam = TRUE
# nx:       Number of points in "time" direction you want in the filal smoothed data
# ny:       Number of points in "depth" direction you want in the filal smoothed data

okokyst_make_plotdata <- function(data, varname, 
                                  gam = FALSE, gam_k = 20, linear = FALSE,
                                  nx = 100, ny = 100){                     
  data <- as.data.frame(data)
  sel <- complete.cases(data[,c("Time", "Depth", varname)])
  data <- dplyr::rename(data, "z" = varname)
  # Interpolation
  data$Time2 <- as.numeric(data$Time)/86400    # convert to day-scale, for better interpolation
  if (!gam){
    interpol <- with(data[sel,], akima::interp(Time2, Depth, z, nx = nx, ny = ny, linear = FALSE))   # spline
    # Reshaping data
    dimnames(interpol$z)[[2]] <- interpol$y
    result <- as.data.frame(interpol$z) %>%
      data.frame(x = interpol$x, .) %>%
      tidyr::gather(key = "y", value = "z", -x) %>%
      mutate(Depth = as.numeric(sub("X", "", y)),
             Time = as.POSIXct(x*86400, origin = "1970-01-01")) %>%
      select(-y)
  } else {
    model <- gam(z ~ te(Time2, Depth, k = gam_k), data = data[sel,])
    result <- with(
      data[sel,],
      expand.grid(
        Time2 = seq(min(Time2), max(Time2), length = nx),
        Depth = seq(min(Depth), max(Depth), length = ny)
      ))
    result$z <- predict.gam(model, result)
    result$Time <- as.POSIXct(result$Time2*86400, origin = "1970-01-01", tz = "GMT")
    # Make maximum depth for every time in smooth
    times_smooth <- sort(unique(result$Time2))
    smooth_maxdepth <- data.frame(
      Time2 = times_smooth,
      Max_depth = seq_along(times_smooth) %>% map_dbl(get_maxdepth, obsdata = data[sel,], smoothdata = result)
    )
    # Add maximum depth to smoothed data, and filter data so we keep only 
    #   data < maximum depth
    result <- result %>%
      left_join(smooth_maxdepth, by = "Time2") %>%
      filter(Depth <= Max_depth)
  }
  result
  }

# df_plot <- okokyst_make_plotdata(df_ctd, "salt")
# df_plot <- okokyst_make_plotdata(df_ctd, "salt", gam = TRUE)

okokyst_plot <- function(data, varname, ctd_variable, title = "", 
                         binwidth = 1, limits = c(NA,NA), color_ctdtime = "black", 
                         gam = FALSE, gam_k = 20, linear = FALSE,
                         nx = 100, ny = 100){
  df_plot <- okokyst_make_plotdata(data, varname, 
                                   gam = gam, gam_k = gam_k, linear = linear,
                                   nx = ny, ny = ny)
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


# For times_smooth number i, return
#  maximum depth for all data within 15 days  
# Assume that variables z, Time2 and Depth exists in both data sets
get_maxdepth <- function(i, max_timediff = 15, obsdata, smoothdata){
  data_maxdepth <- obsdata %>% 
    group_by(Time2) %>%
    summarise(Max_depth = max(Depth))
  times_smooth <- sort(unique(smoothdata$Time2))
  obsdata %>% 
    count(Time2) %>%
    mutate(Timediff = abs(times_smooth[i] - Time2))%>%
    select(-n) %>%
    # just add column from data_maxdepth, doon't need join as times should be identical 
    mutate(Max_depth = data_maxdepth$Max_depth) %>% 
    filter(Timediff <= max_timediff) %>%
    summarise(Max_depth = max(Max_depth)) %>%
    pull(Max_depth)
}

# Ins
# get_maxdepth(df_ctd, "temp")

# sel <- complete.cases(data[,c("Time", "Depth", varname)])
# data <- dplyr::rename(data, "z" = varname)
# # Interpolation
# data$Time2 <- as.numeric(data$Time)/86400    # convert to day-scale, for better interpolation

okokyst_remove_nodata <- function(){
  # Test
  # get_maxdepth(2)
  
  # Make maximum depth for every time in smooth
  smooth_maxdepth <- data.frame(
    Time_num = times_smooth,
    Max_depth = seq_along(times_smooth) %>% map_dbl(get_maxdepth)
  )
  smooth_maxdepth
  
  # Add maximum depth to smoothed data, and filter data so we keep only 
  #   data < maximum depth
  df_smooth <- df_smooth %>%
    left_join(smooth_maxdepth) %>%
    filter(Depth_mid <= Max_depth)
}
