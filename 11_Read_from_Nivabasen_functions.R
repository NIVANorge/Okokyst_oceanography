
#
# Functions for script 11 ----
#

#
# Given a data frame of water samples (e.g. all samples from one station),
#   get all data from one or several dates
#

get_data_given_date <- function(times, data_samples, data_methods){
  
  df_data <- get_nivabase_selection(
    "WATER_SAMPLE_ID, METHOD_ID, VALUE, UNCERTAINTY, FLAG1, FLAG2, REMARK",
    "WATER_CHEMISTRY_VALUES",
    "WATER_SAMPLE_ID",
    subset(df_samples, SAMPLE_DATE %in% times)$WATER_SAMPLE_ID 
  )   
  
  df_methods <- get_nivabase_selection(
    "METHOD_ID, NAME, UNIT, BASIS_ID",
    "METHOD_DEFINITIONS",
    "METHOD_ID",
    unique(df_data$METHOD_ID) 
  )   
  
  df_data <- df_data %>% 
    left_join(data_methods, by = "METHOD_ID") %>%
    left_join(data_samples, by = "WATER_SAMPLE_ID")
  
  df_data
  
}

# Example
# test <- get_data_given_date(ymd_hms(c("2018-02-02 16:06:00 UTC", "2018-02-02 16:37:00 UTC")),
#                     df_samples, df_methods)


# Get data frame of samples from a sinlge station (STATION_CODE is input)
# Returns NULL if no stations

# GLobal variable: df_station
get_samples_onestation <- function(stationcode, 
                                   depth1 = NULL,
                                   date_from = NULL,
                                   date_to = NULL,
                                   stationdata = df_stations
                                   ){
  df_station <- stationdata %>% 
    filter(STATION_CODE %in% stationcode)
  station_ids <- unique(df_station$STATION_ID)
  if (is.null(depth1)){
    extra_where = ""
  } else {
    extra_where = paste0(
      " and DEPTH1 in (",
      depth1 %>% paste(collapse = ","),
      ")"
    )
  }
  if (!is.null(date_from)){
    old.o <- options(useFancyQuotes = FALSE)
    extra_where = paste0(
      extra_where,
      " and SAMPLE_DATE >= to_date(",
      sQuote(date_from), 
      ", 'DD-MM-YYYY')"
    )
    options(old.o)
  }
  if (!is.null(date_to)){
    old.o <- options(useFancyQuotes = FALSE)
    extra_where = paste0(
      extra_where,
      " and SAMPLE_DATE <= to_date(",
      sQuote(date_to), 
      ", 'DD-MM-YYYY')"
    )
    options(old.o)
  }
  df_samples <- get_nivabase_selection(
    "WATER_SAMPLE_ID, STATION_ID, SAMPLE_DATE, DEPTH1, DEPTH2",
    "WATER_SAMPLES",
    "STATION_ID",
    station_ids,
    extra_where = extra_where
  )   
  if (nrow(df_samples) > 0){
    result <- data.frame(
      STATION_CODE = stationcode,
      df_samples,
      stringsAsFactors = FALSE)
  } else {
    result <- NULL
  }
  result
}

# Examples
# df <- get_samples_onestation("VT67")

# Get only data for nutrient depths:
# df <- get_samples_onestation("VR51", depth1 = c(0,5,10,20,30))   

# Add specifications for 
# df <- get_samples_onestation("VR51", depth1 = c(0,5,10,20,30), date_from = "01-01-2016")
# df <- get_samples_onestation("VR51", depth1 = c(0,5,10,20,30), date_from = "01-01-2016", date_to = "31-12-2016")   # get only data for nutrient depths

plot_sampledates <- function(data_samples, years = 2017:2019){
  df <- tibble(Date = unique(df_samples$SAMPLE_DATE), Y = 0.5)
  
  gg <- df %>%
    filter(year(Date) %in% years) %>%
    ggplot() +
    geom_text(aes(Date, Y, label = Date), angle = 90, size = 2) +
    theme(axis.text = element_blank(),
          axis.title = element_blank())
  
  print(gg)
  invisible(gg)
}

# Example
# plot_sampledates(df, 2018:2019)



#
# Functions for script 17 ----
# (These are better made in my opinion)  
# 
# All
#
# OVERVIEW by example
if (FALSE){
  
  # Get all stations (i.e., STATION_ID) given station code 
  df_stations <- get_station_id(c("VR51", "VT71"))  # note that VT71 summarises project IDs to '10446;11946'
  
  # Get all samples given station code and (optionally) year(s)
  df_samples <- get_water_samples("VR51", 2019:2020)

  # Get all data given station code and (optionally) parameter(s) and year(s)
  df_chem <- get_water_chemistry("VR51", parameters = "NO3+NO2-N", years = 2020)
  
  # Helper function: get all methods (i.e., METHOD_ID) given a parameter name
  df_m <- get_methods("NO3+NO2-N")
  
  }


#
# Get methods from METHOD_DEFINITIONS (with METHOD_ID) based on parameters  
#
# Note that NAME and UNIT in the parameter table are renamed PARAM_NAME and PARAM_UNIT
get_methods <- function(parameters){
  df_par <- get_nivabase_selection("*", "WC_PARAMETER_DEFINITIONS", "NAME", parameters, values_are_text = TRUE)
  
  df_mpar  <- get_nivabase_selection(
    "PARAMETER_ID, METHOD_ID, CONVERSION_FACTOR", "WC_PARAMETERS_METHODS", 
    "PARAMETER_ID", df_par$PARAMETER_ID)
  
  df_m <- get_nivabase_selection(
    "METHOD_ID, NAME, UNIT, LABORATORY, DESCR, MATRIX, CAS, IUPAC", 
    "METHOD_DEFINITIONS", 
    "METHOD_ID", 
    unique(df_mpar$METHOD_ID))
  
  df_par %>% 
    select(PARAMETER_ID, NAME, UNIT) %>%
    rename(PARAM_NAME = NAME, PARAM_UNIT = UNIT) %>%
    left_join(df_mpar, by = "PARAMETER_ID") %>%
    left_join(df_m, by = "METHOD_ID")
}

# test
if (FALSE){
  par_names <- c("NO3+NO2-N", "NH4-N", "TOTP", "PO4-P", "SiO2",
                 "KlfA", "TSM",
                 "TOTN (old EF)", "TOTN", "TOTN (est.)")
  df_m <- get_methods(par_names)
  nrow(df_m)  # 237 lines
}


#
# get_station_id
#
# From station codes, get a data frame with station IDs
#
# Somewhat complex due to the fact that 
# - there can be several STATION_CODE per STATION_ID  
# - there are often several PROJECT_ID for the same STATION_ID/STATION_CODE combination
# See examples below!


# Return data set with one line per STATION_ID   
get_station_id <- function(stationcodes, 
                           project_ids = NULL,
                           allow_several_projects = TRUE,
                           allow_duplicate_station_codes = FALSE){
  
  df_projstat <- get_nivabase_selection(
    "PROJECT_ID, STATION_ID, STATION_CODE, STATION_NAME, STATION_IS_ACTIVE", 
    "PROJECTS_STATIONS", 
    "STATION_CODE", 
    stationcodes, values_are_text = TRUE)
  
  if (!is.null(project_ids)){
    df_projstat <- df_projstat %>%
      filter(PROJECT_ID %in% project_ids)
  }
  
  if (allow_several_projects){
    if (allow_duplicate_station_codes){
      df_projstat <- df_projstat %>%
        group_by(STATION_ID) %>%
        summarise(across(.fns = function(x) paste(unique(x), collapse = ";")),
                  .groups = "drop")
    } else {
      df_projstat <- df_projstat %>%
        group_by(STATION_ID, STATION_CODE) %>%
        summarise(across(.fns = function(x) paste(unique(x), collapse = ";")),
                  .groups = "drop")
      
      # Check for duplicate stations ()  
      check <- df_projstat %>% 
        group_by(STATION_ID) %>% 
        mutate(n = n()) %>% 
        filter(n > 1)
      
      if (nrow(check) > 0){
        stations_with_same_STATION_ID <<- check
        stop("Several stations with same STATION_ID. \n  Inspect data set 'stations_with_same_STATION_ID'")
      }
      
    }
  } else {
    check <- df_projstat %>% 
      group_by(STATION_ID, STATION_CODE) %>% 
      mutate(n = n()) %>% 
      filter(n > 1)
    
    if (nrow(check) > 0){
      stations_with_same_ID_and_CODE <<- check
      stop("Several stations with same STATION_ID and STATION_CODE. \n  Inspect data set 'stations_with_same_ID_and_CODE'")
    }
  }
  
  df_projstat
}


# test
if (FALSE){
  #
  # 1. This results in error because VT71 and Skinnbrokleia both have the same STATION_ID
  #
  df_stations <- get_station_id(c("Skinnbrokleia", "VR51", "VT71"))
  # - resolve error, a: delete one station
  df_stations <- get_station_id(c("VR51", "VT71"))  # note that VT71 summarises project IDs to '10446;11946'
  # - resolve error, b: let it summarize STATION_CODE to 'Skinnbrokleia;VT71' in a single line
  df_stations <- get_station_id(c("Skinnbrokleia", "VR51", "VT71"), allow_duplicate_station_codes = TRUE)
  
  #
  # 2. By default, allow_several_projects is TRUE (see 1a above). If false, this results in error:
  #
  df_stations <- get_station_id(c("VR51", "VT71"), allow_several_projects = FALSE)
  # - resolve error: filter by PROJECT_ID
  df_stations <- get_station_id(c("VR51", "VT71"), allow_several_projects = FALSE, project_ids = 10446)
}




#
# get_water_samples
#
# Gets water samples (one line per sample) given station codes,
# Can also supply years and project_ids 
#
# Uses 'get_station_id' to get a station data frame with one line per unique STATION_ID
# Could also be modified to include depths   
#
get_water_samples <- function(stationcodes, years = NULL, 
                              project_ids = NULL,
                              allow_several_projects = TRUE,
                              allow_duplicate_station_codes = FALSE){
  
  df_projstat <- get_station_id(stationcodes = stationcodes,
                                project_ids = project_ids,
                                allow_several_projects = allow_several_projects,
                                allow_duplicate_station_codes = allow_duplicate_station_codes)
  
  if (!is.null(years)){
    yearstring <- paste0("(", years %>% paste(collapse = ","), ")")
    extra_where <- paste(" and extract(YEAR from SAMPLE_DATE) in", yearstring)
  } else {
    extra_where <- ""
  }
  
  df_watersamp <- get_nivabase_selection(
    "WATER_SAMPLE_ID, STATION_ID, SAMPLE_DATE, DEPTH1, DEPTH2, REMARK, SAMPLE_POINT_ID",
    "WATER_SAMPLES", 
    "STATION_ID", 
    unique(df_projstat$STATION_ID),
    extra_where = extra_where) 
  
  df_projstat %>%
    left_join(df_watersamp, by = "STATION_ID")
  
} 

# TEST
if (FALSE){
  df_samples <- get_water_samples("VR51")
  df_samples <- get_water_samples("VR51", 2019:2020)
}



#
# get_water_chemistry
#
# 


get_water_chemistry <- function(stationcodes, 
                                parameters = NULL, 
                                years = NULL,          # this + the ones below: used in get_water_samples  
                                project_ids = NULL,
                                allow_several_projects = TRUE,
                                allow_duplicate_station_codes = FALSE){
  
  df_samples <- get_water_samples(stationcodes = stationcodes,
                                  years = years,
                                  project_ids = project_ids,
                                  allow_several_projects = allow_several_projects,
                                  allow_duplicate_station_codes = allow_duplicate_station_codes)
  
  if (!is.null(parameters)){
    
    df_m <- get_methods(parameters)
    method_id <- unique(df_m$METHOD_ID)
    method_id <- method_id[!is.na(method_id)]
    
    methodstring <- paste0("(", paste(method_id, collapse = ","), ")")
    extra_where <- paste(" and METHOD_ID in", methodstring)
  } else {
    extra_where <- ""
  }
  
  df_waterchem <- get_nivabase_selection(
    "WATER_SAMPLE_ID, METHOD_ID, VALUE, UNCERTAINTY, FLAG1, FLAG2, REMARK, APPROVED", 
    "WATER_CHEMISTRY_VALUES", 
    "WATER_SAMPLE_ID", 
    df_samples$WATER_SAMPLE_ID,
    extra_where = extra_where) %>%
    rename(REMARK_SAMPLE = REMARK)
  
  df_samples %>%
    right_join(df_waterchem, by = "WATER_SAMPLE_ID") %>%
    left_join(df_m, by = "METHOD_ID") %>%
    select(PROJECT_ID, STATION_ID, STATION_CODE, STATION_NAME, SAMPLE_DATE, DEPTH1, DEPTH2, 
           PARAM_NAME, PARAM_UNIT, CONVERSION_FACTOR, 
           NAME, UNIT, LABORATORY, DESCR, MATRIX, CAS, IUPAC, 
           VALUE, UNCERTAINTY, FLAG1, FLAG2, 
           APPROVED, STATION_IS_ACTIVE, REMARK, REMARK_SAMPLE,
           WATER_SAMPLE_ID, SAMPLE_POINT_ID, METHOD_ID, PARAMETER_ID)
}

# Test
if (FALSE){

  df_chem <- get_water_chemistry("VR51", parameters = "NO3+NO2-N", years = 2020)
  
}



