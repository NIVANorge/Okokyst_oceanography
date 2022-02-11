
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# FUNCTIONS FOR CHECKING EXCEL FILES ---- 
# Checking file names, sheet names and variable names
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

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
read_data_fileno <- function(file_number, df_fileinfo, ...){
  i <- file_number
  fn <- with(df_fileinfo[i,], paste0(basefolder, Folder, "/", File))
  read_excel_droplines(fn, sheet = df_fileinfo$Sheet[i], ...)
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


#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# FUNCTIONS FOR READING DATA ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o


#
# Read excel file which has column names in first row, then (typically) units in the second row and data from 3rd row
#
read_excel_droplines <- function(fn, sheetname, first_data_row = 3, cut_columns = FALSE, ...){
  # Read top line, only for the column names
  df_names <- read_excel(fn, sheet = sheetname, col_names = TRUE, n_max = first_data_row)
  # Read data. All data is read as text (strings) and later converted, due to the "<" signs
  data <- read_excel(fn, sheet = sheetname, col_names = FALSE, skip = first_data_row-1, ...)
  # Set column names (copy them from df_names)
  if (ncol(df_names) == ncol(data) | cut_columns){
    names(data) <- names(df_names)[1:ncol(data)]
  } else {
    stop("First line doesn't have the same number of columns as the rest of the file!")
  }
  data
}

# Example
# fn <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor1_RMS/xlsbase/TilAquamonitor/?kokyst_Norskehavet_S?r1_CTD_2017.xlsm"
# read_excel_droplines(fn, "data")

read_excel_til_AqM <- function(fn, sheetname, first_data_row = 5, 
                               header1_col = 1:9, header1_row = 4,
                               header2_col = 10:13, header2_row = 2, ...){
  # Read top line, only for the column names
  df_names1 <- read_excel(fn, sheet = sheetname, col_names = TRUE, n_max = 1, skip = header1_row-1)[header1_col]
  df_names2 <- read_excel(fn, sheet = sheetname, col_names = TRUE, n_max = 1, skip = header2_row-1)[header2_col]
  # Read data. All data is read as text (strings) and later converted, due to the "<" signs
  data <- read_excel(fn, sheet = sheetname, col_names = FALSE, skip = first_data_row-1, ...)
  # Set column names (copy them from df_names)
  if (TRUE){
    names(data)[header1_col] <- names(df_names1)
    names(data)[header2_col] <- names(df_names2)
  } else {
    stop("First line doesn't have the same number of columns as the rest of the file!")
  }
  data
}

# Example
# datafolder1 <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor2_Aquakompetanse/xlsbase"
# datafolder1 <- "Datasett/OKOKYST_NH_Sor2_Aquakompetanse/xlsbase"
# fn <- paste0(datafolder1, "/TilAquamonitor/VR52_CTD+siktdyp_2019_Til_AqM.xlsm")
# # debugonce(read_excel_til_AqM)
# test <- read_excel_til_AqM(fn, "CTD")



#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# FUNCTIONS FOR General QC ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

#
# For a given variable, plots min, max, and mean value for all stations and months (and years)
#

plot_statistics_variable <- function(data, variable){
  data %>%
    filter(PARAM_NAME == variable & !is.na(VALUE)) %>%
    group_by(Year, Month, STATION_CODE) %>%
    summarise(Max = max(VALUE),
              Min = min(VALUE),
              Mean = mean(VALUE), .groups = "drop") %>%
    pivot_longer(cols = Max:Mean, names_to = "Statistic", values_to = "Value") %>%
    ggplot(aes(Month, STATION_CODE, fill = Value)) +
    geom_tile() +
    scale_fill_viridis_c() +
    scale_x_continuous(breaks = seq(1,11,2)) +
    facet_grid(vars(Year), vars(Statistic)) 
}


#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# FUNCTIONS FOR CTD QC ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

#
# Plot cast (i.e. Depth along each profile)
#
# Note hard-coded columns 'Temperatur' and 'Saltholdighet'
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
    filter(!is.na(Temperatur) | !is.na(Saltholdighet)) %>%       
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
                      titletext = paste0("Plot ", i, ", File ", file_no, " ", 
                                         sQuote(df_fileinfo_stations$File[i]))
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
plot_ctdprofile_station <- function(stationcode, data, variable, titletext = "", 
                                    limits = NULL, points = FALSE, referencelines = NULL,
                                    year_by_month = FALSE,
                                    maxdepth = NULL, maxvalue = NULL){
  if ("StationCode" %in% names(data)){
    df <- data %>%
      filter(StationCode %in% stationcode & !is.na(.data[[variable]]))
    if (nrow(df) == 0){
      stop("No data found for this StationCode value")
    }
  } else {
    df <- data %>%
      filter(StationId %in% stationcode & !is.na(.data[[variable]]))
    if (nrow(df) == 0){
      stop("No data found for this StationId value")
    }
  }
  if (sum(c("Year","Month") %in% names(df)) < 2 & year_by_month){
    df <- df %>%
      mutate(Year = lubridate::year(Date),
             Month = lubridate::month(Date))
  }
  df <- df %>%
    group_by(Date) %>%
    mutate(n = n()) %>%
    filter(n > 1) %>%
    ungroup()
  if (nrow(df) > 0){
    gg <- df %>%
      mutate(Date = factor(Date)) %>%
      ggplot(aes(.data[[variable]], Depth1, group = Date)) +
      geom_path() + 
      labs(title = paste(titletext, stationcode, " - ", variable),
           x = variable) +
      theme(axis.text.x = element_text(angle = -45, hjust = 0))
    if (!is.null(maxdepth)){
      gg <- gg + scale_y_reverse(limits = c(maxdepth, 0))
    } else {
      gg <- gg + scale_y_reverse()
    }
    if (!is.null(maxvalue)){
      gg <- gg + scale_x_continuous(limits = c(0, maxvalue))
    }
    if (year_by_month){
      gg <- gg + facet_grid(rows = vars(Year), cols = vars(Month), drop = FALSE)
    } else {  
      gg <- gg + facet_wrap(vars(Date))
    }
    if (points){
      gg <- gg + geom_point()
    }
    if (!is.null(limits)){
      gg <- gg + geom_vline(xintercept = limits, linetype = 2, color = "red3")
    }
    if (!is.null(referencelines)){
      gg <- gg + geom_vline(aes(xintercept = referencelines), linetype = 2)
    }
    print(gg)
  }
}

# Example
# fn <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor1_RMS/xlsbase/TilAquamonitor/?kokyst_Norskehavet_S?r1_CTD_2017.xlsm"
# dat <- read_excel_droplines(fn, "data")
# plot_ctdprofile_station("VR51", dat, "Saltholdighet")

#
# Plot profiles for several parameters
#
# Otherwise simular to 'plot_ctdprofile_station'
#
# titletext1 is added at start of title
# titletext2 is added at end of title
# interactive = TRUE will give an interactive plot with tooltip

plot_ctdprofile_station_multi <- function(stationcode, data, variables, 
                                          titletext1 = "", titletext2 = "",
                                          limits = NULL, 
                                          points = FALSE,
                                          interactive = FALSE){
  if (!"StationCode" %in% names(data)){
    df <- data %>% rename(StationId = StationCode)
  } else {
    df <- data
  }
  df <- df[c("StationCode", "Date", "Depth1", variables)] %>%
    filter(StationCode %in% stationcode) %>%
    pivot_longer(-c(StationCode, Date, Depth1), 
                 names_to = "Variable",
                 values_to = "Value") %>%
    filter(!is.na(Value)) %>%
    # For getting ride of profiles with only one depth
    group_by(Variable, Date) %>%
    mutate(n = n()) %>%
    filter(n > 1) %>%
    ungroup()
  if (nrow(df) > 0){
    gg <- df %>%
      mutate(Date = factor(Date)) %>%
      ggplot(aes(Value, Depth1, color = Variable)) +
      geom_path() +
      scale_y_reverse() + 
      facet_wrap("Date") +
      labs(title = paste(titletext1, stationcode, " - ", titletext2))
    if (points & !interactive){
      gg <- gg + geom_point()
    } else if (points & interactive){
      gg <- gg + geom_point_interactive(aes(tooltip = Value))
    }
    if (!is.null(limits)){
      gg <- gg + geom_vline(xintercept = limits, linetype = 2, color = "red3")
    }
    if (interactive){
      girafe(ggobj = gg)
    } else {
      print(gg)
    }
  }
}
# Examples:
if (FALSE){
  plot_ctdprofile_station_multi("VT16", data = dat,
                                variables = c("PO4-P", "TOTP"),
                                points = TRUE, titletext2 = "Phosphorus")
  plot_ctdprofile_station_multi("VT16", data = dat,
                                variables = c("PO4-P", "TOTP"),
                                points = TRUE, titletext2 = "Phosphorus",
                                interactive = TRUE)
  
  # NOTE: interactive doesn't work with purrr::walk or for-next loop
  plot_ctdprofile_station_multi("VT16", data = dat,
                                variables = c("PO4-P", "TOTP"),
                                points = TRUE, titletext2 = "Phosphorus",
                                interactive = TRUE)
  
}


#
# Plot all profiles, function      
# Note the default 'fileinfo_stations'
#
plot_ctdprofile_all <- function(variable, df_fileinfo_stations = fileinfo_stations, limits = NULL){
  for (i in seq_len(nrow(df_fileinfo_stations))){
    dat <- get_data_filestation(i)
    file_no <- df_fileinfo_stations$File_no[i]
    plot_ctdprofile_station(df_fileinfo_stations$StationCode[i], 
                            dat, 
                            variable, 
                            titletext = paste0("Plot ", i, ", File ", file_no, " ",
                                               sQuote(df_fileinfo_stations$File[i]), " -"),
                            limits = limits
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
    filter(!is.na(.data[[variable]])) %>%
    mutate(Depth = case_when(
      Depth1 == 0 ~ 0,
      Depth1 > 0 ~ round((Depth1+Depth2)/2, 0) 
    ))
  
  # Test colors
  # Colors chosen using 
  #    pal <- colorspace::choose_palette()
  #    In menu: Sequential (multiple hues)
  #    h = c(131, -96), c. = c(80, 48), l = c(59, 30), power = c(0.967, 1.244)
  # 10 colors (if we include minimum max-depth)
  colors <- c("#18A439", "#689100", "#867D00", "#966900", "#9D5529", "#9D4250", 
              "#94336A", "#832F7A", "#673581", "#3C417E")
  maxdepth_by_date <- df %>%
    group_by(Date) %>%
    summarise(Max_depth = max(Depth, na.rm = TRUE), .groups = "drop") %>%
    pull(Max_depth)
  depths <- c(0, 1, 5, 10, 20, 50, 100, 200)
  # If minimum max-depth is >10% lower than median max-depth ,we plot it
  if (min(maxdepth_by_date) < 0.9*median(maxdepth_by_date)){   
    depths <- c(depths, min(maxdepth_by_date))
  } else {
    colors <- colors[-9]
  }
  # Add median maximum depth minus 10 meters
  depths <- c(depths, round(median(maxdepth_by_date),0) - 10)
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
                            titletext = paste0("Plot ", i, ", File ", file_no, " ",
                                               sQuote(df_fileinfo_stations$File[i]), " -")
    )
  }
}
# plot_timeseries_all("Saltholdighet")


#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# FUNCTIONS FOR COMPARING DATA FRAMES ----
#
# Building on package 'compareDF'  
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

#
# Get differences for a single variable
# - Returns a data set wth one column and 10 rows (see row names given in function)
# - Also handles non-numeric rows  
# - For use within get_differences_variables()
# 


#
get_differences_one_variable <- function(comparison_output, var){
  
  changes <- table(comparison_output$comparison_df$chng_type)
  if (changes["+"] != changes["-"])
    stop("Function works only for data frames with same number of rows and the same grouping variables. Sorry.")
  
  # NOTE TO SELF: should probably do something like this instead of matrix(ncol = 2)
  # df <- ctab2$comparison_df[c("Depth1", "chng_type", "Oksygen")] %>% 
  #   pivot_wider(names_from = "chng_type", values_from = "Oksygen")
  
  
  result <- data.frame(
    x = rep(NA, 10)
  )
  names(result) <- var
  row.names(result) <- c(
    "NA_in_both",
    "NA_only_in_1",
    "NA_only_in_2",
    "Different_value",
    "Highest_in_1",
    "Highest_in_2",
    "Highest_in_1_meandiff",
    "Highest_in_2_meandiff",
    "Highest_in_1_maxdiff",
    "Highest_in_2_maxdiff"
  )
  
  # Actual values
  tab <- comparison_output$comparison_df[[var]] %>% 
    matrix(ncol = 2, byrow = TRUE)
  # head(tab)
  result["NA_in_both",] <- sum(is.na(tab[,1]) & is.na(tab[,2]))    # Number of NAs in df1 + df2
  result["NA_only_in_1",] <- sum(is.na(tab[,1]) > is.na(tab[,2]))  # Number of NAs in df1
  result["NA_only_in_2",] <- sum(is.na(tab[,1]) < is.na(tab[,2]))  # Number of NAs in df2
  
  # Where values in both tables  
  sel_notNA <- !is.na(tab[,1]) & !is.na(tab[,2])
  
  # Pick rows with difference in values  
  sel_different <- tab[sel_notNA,1] != tab[sel_notNA,2]
  result["Different_value",] <- sum(sel_different)    # Number of rows where df1 > df2  
  
  # For numeric variables only
  if (mode(comparison_output$comparison_df[[var]]) == "numeric"){
    
    # Pick rows with specific difference in values  
    sel_highest_is_1 <- tab[sel_notNA,1] > tab[sel_notNA,2]
    sel_highest_is_2 <- tab[sel_notNA,1] < tab[sel_notNA,2]
    result["Highest_in_1",] <- sum(sel_highest_is_1)    # Number of rows where df1 > df2  
    result["Highest_in_2",] <-sum(sel_highest_is_2)    # Number of rows where df2 > df1  
    
    # Make table for vales with differences
    tab_highest_is_1 <- tab[sel_notNA,][sel_highest_is_1,] %>% matrix(ncol = 2)
    tab_highest_is_2 <- tab[sel_notNA,][sel_highest_is_2,] %>% matrix(ncol = 2)
    
    # Difference where 1 is highest, every difference (may be long)
    # apply(tab_highest_is_1, 1, diff) 
    
    # Mean differences
    if (sum(tab_highest_is_1) > 0){
      result["Highest_in_1_meandiff",] <- apply(tab_highest_is_1, 1, diff) %>% mean()
      result["Highest_in_1_maxdiff",] <- apply(tab_highest_is_1, 1, diff) %>% min()
    }
    if (sum(tab_highest_is_2) > 0){
      result["Highest_in_2_meandiff",] <- apply(tab_highest_is_2, 1, diff) %>% mean()
      result["Highest_in_2_maxdiff",] <- apply(tab_highest_is_2, 1, diff) %>% max()
    }

  }
  
  result
  
}

# TEST
if (FALSE){
  
  library(compareDF)
  
  # Two versions of same data
  df1 <-   dat     %>% filter(StationCode %in% "VT69")
  df2 <-   dat_old %>% filter(StationCode %in% "VT69") 
  
  # Group on date and depth - create_output_table gives much better input  
  ctab2 <- compare_df(df1, df2, c("Date", "Depth1"))
  
  get_differences_one_variable(ctab2, "Temperatur")
  get_differences_one_variable(ctab2, "Oksygen")
  get_differences_one_variable(ctab2, "Metode")

  
}


#
# Get differences for a data frame, by variables  
# - Returns a data set wth one column and 10 rows (see row names given in function)
# - Also handles non-numeric rows  
# - For use within get_differences_variables()
# 

get_differences_by_variable <- function(comparison_output){
  
  vars <- names(comparison_output$comparison_df)
  vars <- vars[!vars %in% c("grp","chng_type","...3")]
  
  vars %>% purrr::map_dfc(
    ~get_differences_one_variable( 
      comparison_output = comparison_output,
      var = .x)
  )
  
}

# TEST
if (FALSE) {
  
  # Two versions of same data
  df1 <-   dat     %>% filter(StationCode %in% "VT69")
  df2 <-   dat_old %>% filter(StationCode %in% "VT69") 
  
  # Group on date and depth - create_output_table gives much better input  
  ctab2 <- compare_df(df1, df2, c("Date", "Depth1"))
  
  get_differences_by_variable(ctab2)
  
}

