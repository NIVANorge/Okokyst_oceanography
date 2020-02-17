# Reads and shows latest data from ftp-myocean.niva.no
# Reading from ferrybox folder (not from 'myocean' folder)

# based on code from "test read ferrybox txt and bz2 files.R"

library(RCurl)
library(plyr)

url.base <- "ftp://ftp-myocean.niva.no/ferrybox/niva/"


##########################################################################################################################
# 40. lsFTP                 
#     Makes a data frame of the contents (files, folders) of an ftp site, including date, file size etc.
##########################################################################################################################

lsFTP <- function(url, userpwd=NULL){
  require(RCurl) 
  if (is.null(userpwd)){
    ftp_options <- curlOptions(ftp.use.epsv = FALSE, dirlistonly = FALSE)
  } else {
    ftp_options <- curlOptions(userpwd = userpwd, ftp.use.epsv = FALSE, dirlistonly = FALSE)
  }
  files1 <- getURL(url, verbose = TRUE, .opts = ftp_options)
  files2 <- strsplit(files1, "\r\n")[[1]]
  # in order to separate fields using whitespace, write files2 to a temporary file and read it using read.table()
  tmp <- tempfile()
  writeLines(files2, tmp)
  df <- read.table(tmp, stringsAsFactors=FALSE)
  colnames(df) <- c('rights', 'number', 'user', 'group', 'size', 'month', 'day', 'time', 'filename')
  df
  }

get_one_logfile <- function(filename, vessel, tmpfile = "tmp_fb.zip", default = TRUE){
  url.folder <- get_url_foldername(vessel)
  ftptxt <- paste(url.folder, filename, sep="/")
  bin <- getBinaryURL(ftptxt, ssl.verifypeer=FALSE, userpwd = "niva:varsog", verbose = TRUE)
  con <- file(paste0(tempdir(), "/", tmpfile), open = "wb")
  writeBin(bin, con)
  close(con)
  if (default) {
    read.table(paste0(tempdir(), "/", tmpfile))
  } else {
    read.table(paste0(tempdir(), "/", tmpfile), sep = "\t", dec = ",", stringsAsFactors = FALSE)
  }
  }

# fb_data <- get_one_logfile(filename = tail(df_files_fn, 1), url.folder = url.folder)

get_several_logfiles <- function(filenames, vessel, trace = TRUE){
  require(RCurl)
  require(plyr)
  url.folder <- get_url_foldername(vessel)
  h <- getCurlHandle()
  N <- length(filenames)
  for (i in 1:N){
    ftptxt <- paste(url.folder, filenames[i], sep="/")
    if (trace) print(paste("Reading from...", ftptxt))
    bin <- getBinaryURL(ftptxt, ssl.verifypeer=FALSE, userpwd = "niva:varsog", verbose = TRUE, curl=h)
    con <- file(paste0(tempdir(), "/TemporaryDataFile_", i, ".zip"), open = "wb")
    writeBin(bin, con)
    close(con)
  }
  df_list <- vector("list", N)
  for (i in 1:N){
    df_list[[i]] <- try(read.table(paste0(tempdir(), "/TemporaryDataFile_", i, ".zip"), stringsAsFactors = FALSE))
	#if (class(df_list[[i]]) == "try-error")
    #  df_list[[i]] <- try(read.table(paste0(tempdir(), "/TemporaryDataFile_", i, ".zip"), sep = "\t", dec = ","))
  }
  df_list_class <- laply(df_list, class)
  df_list <- df_list[df_list_class != "try-error"]
  if (sum(df_list_class == "try-error") > 0){
    cat("\nNote: There was an error reading from the following file(s):\n")
	print(filenames[df_list_class == "try-error"])
	}
  ldply(df_list, rbind)
  }


#
# Make version returning list instead
# - for cases returning message such as "Error in scan:  line 62895 did not have 22 elements"
#
#
get_several_logfiles_list <- function(filenames, vessel, trace = TRUE){
  require(RCurl)
  require(plyr)
  url.folder <- get_url_foldername(vessel)
  h <- getCurlHandle()
  N <- length(filenames)
  for (i in 1:N){
    ftptxt <- paste(url.folder, filenames[i], sep="/")
    if (trace) print(paste("Reading from...", ftptxt))
    bin <- getBinaryURL(ftptxt, ssl.verifypeer=FALSE, userpwd = "niva:varsog", verbose = TRUE, curl=h)
    con <- file(paste0("C:/Temp/TemporaryDataFile_", i, ".zip"), open = "wb")
    writeBin(bin, con)
    close(con)
  }
  df_list <- vector("list", N)
  for (i in 1:N)
    df_list[[i]] <- try(read.table(paste0("C:/Temp/TemporaryDataFile_", i, ".zip")))
  df_list
  }

  
get_folders <- function(){
  lsFTP(url.base, "niva:varsog")
  }

get_url_foldername <- function(vessel = "trollfjord"){
  paste0(url.base, vessel)
  }

get_filenames_logfiles <- function(vessel = "trollfjord"){
  df_files <- lsFTP(paste0(get_url_foldername(vessel), "/"), "niva:varsog")
  fn <- df_files$filename
  fn[grepl("log_", fn) & !grepl(".md5", fn)]
  }

get_filenames_samplefiles <- function(vessel = "trollfjord"){
  df_files <- lsFTP(paste0(get_url_foldername(vessel), "/"), "niva:varsog")
  fn <- df_files$filename
  fn[grepl("^samples_", fn) & !grepl(".md5$", fn)]
}

#
# Get possible folder names
#
#get_folders()
#
# Get the url for the vessel we want
#
#url.folder <- get_url_foldername("trollfjord")
#
# Get file names of all log files for that vessel
#
#df_files_fn <- get_filenames_logfiles("trollfjord")

#
# Read files
#
# debugonce(get_several_logfiles )
# fb_data <- get_several_logfiles(tail(df_files_fn, 25), vessel = "trollfjord")

##########################################################################################
#
# Variable names
#
##########################################################################################

#
# Variable names for Trollfjord
#
x <- paste(
  c("sensor.TIME sensor.TIME_GPS sensor.LAT sensor.LON sensor.PUMP sensor.OBSTR sensor.MSAMP sensor.ASAMP sensor.VAL sensor.QA sensor.TRIP sensor.TURB"),
  c("sensor.FLU_OLD sensor.FLU_RAW sensor.FLU sensor.TEMP_IN sensor.TEMP sensor.SAL sensor.OX_CONC sensor.OX_SAT sensor.OX_TEMP"),
  c("sensor.AIR_PRES sensor.CDOM_RAW sensor.CDOM sensor.CYANO_RAW sensor.CYANO"),
  c("sensor.ID sensor.FLU_BCORR sensor.FLU_LABCAL sensor.FLU_FIELDCAL sensor.FLU_FIELDCALNATT"))
x <- strsplit(x, " ")[[1]]
txt <- substr(x, 8, nchar(x))

colnames.TF <- c("Vessel", "Date", "TimeOfDay", "Lat", "Lon", "X", txt[5:26])

rm(x, txt)



#
# Variable names for Color Fantasy
#

# String 
str <- "sensor.TIME sensor.TIME_GPS sensor.LAT sensor.LON sensor.PUMP sensor.OBSTR sensor.MSAMP sensor.ASAMP sensor.VAL sensor.QA sensor.TRIP sensor.TURB
  sensor.FLU_OLD sensor.FLU_RAW sensor.FLU sensor.TEMP_IN sensor.TEMP sensor.SAL sensor.OX_CONC sensor.OX_SAT sensor.OX_TEMP
  sensor.AIR_PRES sensor.CDOM_RAW sensor.CDOM sensor.CYANO_RAW sensor.CYANO sensor.OXINSAT sensor.OXINCONC sensor.OXINTEMP
  sensor.ID sensor.FLU_BCORR sensor.FLU_LABCAL sensor.FLU_FIELDCAL"

# Remove line breaks:
str <- gsub("\n", " ", str, fixed=TRUE)
# Remove extra spaces:
str <- gsub("[[:blank:]]+", " ", str)
# Split string
str_split <- strsplit(str, " ")[[1]]
# str_split
txt <- substr(str_split, 8, nchar(str_split))
colnames.FA <- c("Vessel", "Date", "TimeOfDay", "Lat", "Lon", "X", txt[5:29])

rm(txt, str, str_split)
