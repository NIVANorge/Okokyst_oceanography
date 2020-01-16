
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

# Test
# test <- get_data_given_date(ymd_hms(c("2018-02-02 16:06:00 UTC", "2018-02-02 16:37:00 UTC")),
#                     df_samples, df_methods)
