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
#                fn = "Økokyst_Norskehavet_Sør1_CTD_2017.xlsm"
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
# vars_in_file("Økokyst_Norskehavet_Sør1_CTD_2017.xlsm",
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
# FUNCTIONS FOR CTD QC ----
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
# fn <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor1_RMS/xlsbase/TilAquamonitor/Økokyst_Norskehavet_Sør1_CTD_2017.xlsm"
# read_excel_droplines(fn, "data")

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

# Example
# fn <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor1_RMS/xlsbase/TilAquamonitor/Økokyst_Norskehavet_Sør1_CTD_2017.xlsm"
# dat <- read_excel_droplines(fn, "data")
# plot_cast_station("VR51", dat, "Norskehavet_Sør1_CTD_2017")

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
# fn <- "K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017/OKOKYST_NH_Sor1_RMS/xlsbase/TilAquamonitor/Økokyst_Norskehavet_Sør1_CTD_2017.xlsm"
# dat <- read_excel_droplines(fn, "data")
# plot_ctdprofile_station("VR51", dat, "Saltholdighet")


