#
# FUNCTIONS FOR CHECKING EXCEL FILES ---- 
# Checking file names, sheet names and variable names
#
# All outputs contains "folder" in a data frame variable, 
#   but to avoid exceedingly long folder names, one may use the "base folder" 
#   argument, which then will not be port of the output (only the "lower levels" of the folder will be output)

excelfiles_in_folder <- function(folder,
            basefolder = "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/"){
  fns <- dir(paste0(basefolder, folder), ".xls") %>% grep("CTD", ., value = TRUE)
  fns <- fns[!grepl("^~", fns)]   # remove temporary files (opened excel files)
  fns
}
# Example
# excelfiles_in_folder("OKOKYST_NH_Sor1_RMS/xlsbase/TilAquamonitor")

sheets_in_file <- function(folder, fn, 
                           basefolder = "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/"){
  fn_full <- paste0(basefolder, folder, "/", fn)
  sheets <- readxl::excel_sheets(fn_full)
  data.frame(folder = folder, 
             file = fn, 
             columns = paste(sheets, collapse = ","),
             stringsAsFactors = FALSE)
}

# Example
# sheets_in_file(folder = "OKOKYST_NH_Sor1_RMS/xlsbase/TilAquamonitor", 
#                fn = "?kokyst_Norskehavet_S?r1_CTD_2017.xlsm"
#                )

sheets_in_folder <- function(folder, 
                             basefolder = "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/"){
  fns <- excelfiles_in_folder(folder, basefolder = basefolder)
  fns %>% map_df(~sheets_in_file(folder, ., basefolder = basefolder))
}
# Example
# sheets_in_folder(folder = "OKOKYST_NH_Sor1_RMS/xlsbase/TilAquamonitor")

vars_in_file <- function(fn, sheetname, folder, 
                         basefolder = "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/"){
  fn_full <- paste0(basefolder, folder, "/", fn)
  dat_header <- read_excel(fn_full, sheet = sheetname, n_max = 0)
  data.frame(Folder = folder, 
             File = fn, 
             Sheet = sheetname, 
             Variables = paste(names(dat_header), collapse = ","),
             stringsAsFactors = FALSE)
}
# Example
# vars_in_file("?kokyst_Norskehavet_S?r1_CTD_2017.xlsm",
#              "data",
#              "OKOKYST_NH_Sor1_RMS/xlsbase/TilAquamonitor")

vars_in_folder <- function(folder, sheetnames,
                           basefolder = "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/"){
  filenames <- excelfiles_in_folder(folder, basefolder = basefolder)
  pmap_df(
    list(filenames, sheetnames),
    vars_in_file,             # filenames and sheetnames are supplied as arguments 1 and 2 to this function
    folder = folder,          # is supplied as argument to 'vars_i_file'
    basefolder = basefolder   # is supplied as argument to 'vars_i_file'
  )
}
# Example
# sheets_in_folder(folder)                              # 1. Find sheet names here
# vars_in_folder("OKOKYST_NH_Sor1_RMS/xlsbase/TilAquamonitor", 
#                c("data","data","Data"))                # 2. Enter the sheet names here  


#
# Check which files lack a given variable  
#
files_lacking_var <- function(variablename, fileinformation = fileinfo){
  data.frame(
    Variable = variablename, 
    No_of_files_lacking = fileinformation %>%
      filter(!grepl(variablename, Variables)) %>% 
      nrow(),
    stringsAsFactors = FALSE
  )
}
# Variables of first file:
# i <- 1
# fn <- with(fileinfo[1,], paste0(basefolder, Folder, "/", File))
# read_excel(fn, sheet = fileinfo[1,"Sheet"], n_max = 0) %>% names() %>% dput()

#
# Read the data in row number 'file_number' of 'df_fileinfo'
#
# Global variable: basefolder
read_data_fileno <- function(file_number, df_fileinfo){
  i <- file_number
  fn <- with(df_fileinfo[i,], paste0(basefolder, Folder, "/", File))
  read_excel_droplines(fn, sheet = df_fileinfo$Sheet[i])
  }

#
# Read data based on given row number in 'df_fileinfo_stations' file
#
# I.e. gets data from a particular file, and inside that file for a particula station
#
get_data_filestation <- function(i, 
                                   df_fileinfo_stations = fileinfo_stations,
                                   df_fileinfo = fileinfo, 
                                   list_of_dataframes = datalist){
  # fn <- with(df_fileinfo_stations[i,], 
  #            paste0(basefolder, Folder, "/", File))
  # dat <- read_excel_droplines(fn, 
  #                             sheet = df_fileinfo_stations$Sheet[i])
  j <- which(
    df_fileinfo$Folder %in% df_fileinfo_stations$Folder[i] &
      df_fileinfo$File %in% df_fileinfo_stations$File[i]
  )
  if (length(j) == 1){
    dat <- list_of_dataframes[[j]]
  } else if (length(j) > 1){
    cat("Warning! More than one file fits criteria. Check for duplicates in df_fileinfo.\n")
    dat <- list_of_dataframes[[j[1]]]
  } else {
    cat("Warning! No files fits criteria!\n")
    dat <- NULL
  } 
  dat
}
# Example
# get_data_filestation(4)

#
# Makes a data frame for a given file, with one row per station
#
# NOTE: default info data 'fileinfo'
#
get_stations <- function(file_number, df_fileinfo = fileinfo, 
                         list_of_dataframes = datalist){
  i <- file_number
  # fn <- with(df_fileinfo[i,], paste0(basefolder, Folder, "/", File))
  # dat <- read_excel_droplines(fn, sheet = df_fileinfo$Sheet[i])
  dat <- list_of_dataframes[[i]]
  if ("StationCode" %in% names(dat)){
    df <- dat %>% count(StationCode)
    StationCode_var = "StationCode"
  } else {
    df <- dat %>% count(StationId)
    StationCode_var = "StationId"
    names(df)[1] <- "StationCode"
  }
  df$StationCode <- as.character(df$StationCode)
  data.frame(
    Folder = df_fileinfo$Folder[i],
    File = df_fileinfo$File[i],
    Sheet = df_fileinfo$Sheet[i],
    StationCode_var = StationCode_var,
    File_no = i,
    df,
    stringsAsFactors = FALSE
  )
}

# Test
# get_stations(1)
# get_stations(4)


#
# FUNCTIONS FOR READING DATA ----
#


#
# Read excel file which has column names in first row, then (typically) units in the second row and data from 3rd row
#
read_excel_droplines <- function(fn, sheetname, first_data_row = 3){
  # Read top line, only for the column names
  df_names <- read_excel(fn, sheet = sheetname, col_names = TRUE, n_max = 0)
  # Read data. All data is read as text (strings) and later converted, due to the "<" signs
  data <- read_excel(fn, sheet = sheetname, col_names = FALSE, skip = first_data_row-1)
  # Set column names (copy them from df_names)
  if (ncol(df_names) == ncol(data)){
    names(data) <- names(df_names)
  } else {
    stop("First line doensn't have the same number of columns as the rest of the file!")
  }
  data
}

# Example
# fn <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor1_RMS/xlsbase/TilAquamonitor/?kokyst_Norskehavet_S?r1_CTD_2017.xlsm"
# read_excel_droplines(fn, "data")

#
# FUNCTIONS FOR CTD QC ----
#

#
# Plot cast (i.e. Depth along each profile)
#
plot_cast_station <- function(stationcode, data, titletext = ""){
  if ("StationCode" %in% names(data)){
    df <- data %>%
      filter(StationCode %in% stationcode)
  } else {
    df <- data %>%
      filter(StationId %in% stationcode)
  }
  df <- df %>%
    group_by(Date) %>%
    mutate(Observation_no = seq_len(n())) %>%
    ungroup()
  df_max <- df %>%
    group_by(Date) %>%
    summarise(Max_depth = round(max(Depth1),1)) %>%
    mutate()
  depth_range <- range(df_max$Max_depth)
  gg <- df %>%
    mutate(Date = factor(Date)) %>%
    ggplot(aes(x = Observation_no, y = Depth1)) +
    geom_line() +
    scale_y_reverse() +
    geom_text(data = df_max, 
              aes(x = Inf, y = -Inf, label = paste("Max =", Max_depth)), 
              hjust = 1, vjust = 1) +
    facet_wrap("Date") +
    labs(title = 
           paste0(titletext, " - ", stationcode, 
                  " - Range: ", depth_range[1], "-", depth_range[2], " m (diff: ", diff(depth_range),")")
    )
  print(gg)
}


#
# Plot all casts, function
# Note the default 'fileinfo_stations'
#
plot_cast_all <- function(df_fileinfo_stations = fileinfo_stations){
  for (i in seq_len(nrow(df_fileinfo_stations))){
    dat <- get_data_filestation(i)
    file_no <- df_fileinfo_stations$File_no[i]
    plot_cast_station(df_fileinfo_stations$StationCode[i], 
                      dat, 
                      titletext = paste0("Plot ", i, ", File ", file_no)
    )
  }
}
# Example
# plot_cast_all()

#
# Plot profile
#
# Handles the use of both 'StationCode' and 'StationId'  
#
plot_ctdprofile_station <- function(stationcode, data, variable, titletext = ""){
  if ("StationCode" %in% names(data)){
    df <- data %>%
      filter(StationCode %in% stationcode)
  } else {
    df <- data %>%
      filter(StationId %in% stationcode)
  }
  gg <- df %>%
    mutate(Date = factor(Date)) %>%
    ggplot(aes(.data[[variable]], Depth1)) +
    geom_path() +
    scale_y_reverse() + 
    facet_wrap("Date") +
    labs(title = 
           paste(titletext, stationcode, " - ", variable)
    )
  print(gg)
}
# Example
# fn <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor1_RMS/xlsbase/TilAquamonitor/?kokyst_Norskehavet_S?r1_CTD_2017.xlsm"
# dat <- read_excel_droplines(fn, "data")
# plot_ctdprofile_station("VR51", dat, "Saltholdighet")


#
# Plot all profiles, function      
# Note the default 'fileinfo_stations'
#
plot_ctdprofile_all <- function(variable, df_fileinfo_stations = fileinfo_stations){
  for (i in seq_len(nrow(df_fileinfo_stations))){
    dat <- get_data_filestation(i)
    file_no <- df_fileinfo_stations$File_no[i]
    plot_ctdprofile_station(df_fileinfo_stations$StationCode[i], 
                            dat, 
                            variable, 
                            titletext = paste0("Plot ", i, ", File ", file_no, " -")
    )
  }
}

# plot_ctdprofile_all("Saltholdighet")




#
# Plot 
#
plot_timeseries_station <- function(stationcode, data, variable, titletext = ""){
  
  if ("StationCode" %in% names(data)){
    df <- data %>%
      filter(StationCode %in% stationcode)
  } else {
    df <- data %>%
      filter(StationId %in% stationcode)
  }

  df <- df %>%
    mutate(Depth = case_when(
      Depth1 == 0 ~ 0,
      Depth1 > 0 ~ round((Depth1+Depth2)/2, 0) 
    ))
  
  # Test colors
  # Colors chosen using 
  #    pal <- colorspace::choose_palette()
  #    In menu: Sequential (multiple hues)
  #    h = c(131, -96), c. = c(80, 48), l = c(59, 30), power = c(0.967, 1.244)
  depths <- c(0, 1, 5, 10, 20, 50, 100, 200, max(df$Depth)-10)
  colors <- c("#18A439", "#6D8F00", "#8B7800", "#9A6100", "#9E4B3F", "#983861", "#882F77", "#6B3480", "#3C417E")
  names(colors) <- depths

  gg <- df %>%
    filter(Depth %in% depths) %>%
    ggplot(aes(Date, .data[[variable]], group = Depth, color = factor(Depth))) +
    geom_line() + geom_point(size = 1) +
    scale_color_manual(values = colors) +
    theme_bw() +
    labs(title = paste(titletext, stationcode, " - ", variable))
         
  
  print(gg)
  
}


#
# Plot all time series plots, function      
# Note the default 'fileinfo_stations'
#
plot_timeseries_all <- function(variable, df_fileinfo_stations = fileinfo_stations){
  for (i in seq_len(nrow(df_fileinfo_stations))){
    dat <- get_data_filestation(i)
    file_no <- df_fileinfo_stations$File_no[i]
    plot_timeseries_station(df_fileinfo_stations$StationCode[i], 
                            dat, 
                            variable, 
                            titletext = paste0("Plot ", i, ", File ", file_no, " -")
    )
  }
}
# plot_timeseries_all("Saltholdighet")




