#
# READING "WIDE" AQUAMONITOR DATA ----
#

AqMexport_read_waterchemistry <- function(filename, reformat_long = TRUE, remove_duplicates = TRUE, sheetname = "WaterChemistry"){
  # Read top line, only for the column names
  df_names <- read_excel(fn, sheet = sheetname, col_names = TRUE, n_max = 0)
  # Read data. All data is read as text (strings) and later converted, due to the "<" signs
  df_chem <- read_excel(fn, sheet = "WaterChemistry", col_names = FALSE, skip = 2, col_types = "text")
  # Set column names (copy them from df_names)
  if (ncol(df_names) == ncol(df_chem)){
    names(df_chem) <- names(df_names)
  } else {
    cat("Not same number of columns!\n")
  }
  # Convert these variables to numeric
  for (col in c("ProjectId", "SampleDate", "Time", "Depth1", "Depth2")){
    df_chem[[col]] <- as.numeric(df_chem[[col]])
  }
  # UNIX time
  # We just overwrite Time with UNIX time, which is usually just 00:00 anyway
  df_chem$Time <- as.POSIXct((df_chem$SampleDate - 25569)*24*3600, origin = "1970-01-01", tz = "GMT")
  
  # Reformat data to long/narrow format (default option)
  if (reformat_long)
    df_chem <- AqMexport_reformat_long(df_chem, remove_duplicates = remove_duplicates)
  
  df_chem 
  }

# Note hard-coded columns "ProjectId:Depth2"
AqMexport_reformat_long <- function(dat, remove_duplicates = TRUE){
  dat_long <- dat %>%
    pivot_longer(cols = -c(ProjectId:Depth2), names_to = "Variable", values_to = "Value_chr") 
  # Get numeric data values
  x <- sub(",", ".", dat_long$Value_chr, fixed = TRUE)
  x <- sub(",", ".", x, fixed = TRUE)
  dat_long$Value <- as.numeric(sub("<", "", x))
  # Make less-than flag
  dat_long$Flag <- ifelse(grepl("<", dat_long$Value_chr, fixed = TRUE), "<", NA)
  # Get rid of duplicates (several observations, as there are several projects and each value isrepeated for each project)
  if (remove_duplicates)
    dat_long <- AqMexport_remove_duplicates(dat_long)
  dat_long
}
  
AqMexport_remove_duplicates <- function(dat){
  dat %>%
    filter(!is.na(Value)) %>%
    group_by(StationId, StationCode, StationName, Time, Depth1, Depth2, Variable) %>%
    summarise(ProjectId = paste(ProjectId, collapse = ","),
              ProjectName = paste(ProjectName, collapse = "; "),
              Value = first(Value), 
              Flag = first(Flag)) %>%
    ungroup()
}



#
# NUTRIENT PLOTS ----
#
#
# Plotting nutrient time series, based on "long" Aquamonitor data   
#
# - Plots all N variables (colors/circles), plus the sum of inorganic N (NH4 + NO3 + NO2) in black  
# - Dotted vertical lines indicates where the sum is 15% higher than TOTN (example: VT67, 0 m)  
#
# One function for N nutrients, one for P nutrients
#

# Note that gg is invisibly returned by the function and can be used to combine plots using cowplot

nutrient_plot_n <- function(stationcode, depth, years = 2017:2019, print_plot = TRUE, limit = 15){
  
  # Define colors
  cols <- c(brewer.pal(3, "Set1"), "black")
  
  # Data used to make df_line and df2
  df1 <- dat2 %>%
    filter(Depth1 %in% depth & StationCode %in% stationcode & year(Time) %in% years &
             Variable %in% c("TOTN", "NO3+NO2-N", "NH4-N") & 
             !is.na(Value)) %>%
    select(StationCode, Time, Depth1, Variable, Value) %>%
    pivot_wider(names_from = Variable, values_from = Value) %>%
    mutate(Sum = `NO3+NO2-N` + `NH4-N`,
           Percent = round(Sum/TOTN*100, 1))
  
  # Data for plot
  df2 <- df1 %>%
    pivot_longer(-c(StationCode, Time, Depth1, Percent), names_to = "Variable", values_to = "Value") %>%
    mutate(Variable = factor(Variable, levels = c("TOTN", "NO3+NO2-N", "NH4-N", "Sum")))  # For order
  
  # Data used for vertical lines where sum is >= 15% higher than TOTN
  df_line <- df1 %>%
    filter(Percent > (100 + limit))
  
  gg <- ggplot(df2, aes(Time, Value)) +
    geom_vline(xintercept = df_line$Time, color = "black", linetype = 2) +
    geom_line(aes(color = Variable, 
                  linetype = (Variable == "Sum"))) + 
    geom_point(aes(color = Variable,
                   shape = (Variable == "Sum")), size = 2) +
    scale_color_manual(values = cols) +
    labs(title = paste("Station", stationcode, "- depth", depth, "m"))
  
  if (print_plot)
    print(gg)
  
  invisible(gg)
  
}

nutrient_plot_p <- function(stationcode, depth, years = 2017:2019, print_plot = TRUE, limit = 15){
  
  cols <- c(brewer.pal(3, "Set1"), "black")
  
  # Data used to make df_line and df2
  df1 <- dat2 %>%
    filter(Depth1 %in% depth & StationCode %in% stationcode & year(Time) %in% years &
             Variable %in% c("TOTP", "TOTP_P", "PO4-P") & 
             !is.na(Value)) %>%
    select(StationCode, Time, Depth1, Variable, Value) %>%
    pivot_wider(names_from = Variable, values_from = Value) %>%
    mutate(Sum = `PO4-P` + `TOTP_P`,
           Percent = round(Sum/TOTP*100, 1))
  
  # Data for plot
  df2 <- df1 %>%
    pivot_longer(-c(StationCode, Time, Depth1, Percent), names_to = "Variable", values_to = "Value") %>%
    mutate(Variable = factor(Variable, levels = c("TOTP", "TOTP_P", "PO4-P", "Sum")))  # For order
  
  # Data used for vertical lines where sum is >= 15% higher than TOTN
  df_line <- df1 %>%
    filter(Percent > 115) 
  
  # Plot
  gg <- ggplot(df2, aes(Time, Value)) +
    geom_vline(xintercept = df_line$Time, color = "black", linetype = 2) +
    geom_line(aes(color = Variable, 
                  linetype = (Variable == "Sum"))) + 
    geom_point(aes(color = Variable,
                   shape = (Variable == "Sum")), size = 2) +
    scale_color_manual(values = cols) +
    labs(title = paste("Station", stationcode, "- depth", depth, "m"))
  
  if (print_plot)
    print(gg)
  
  invisible(gg)
  
  }


#
# TESTS
#
# nutrient_plot_n("VT67", 0)
# nutrient_plot_p("VT3", 10)

#
# FUNCTIONS FOR CHECKING SUMS ----
#
# Check that the sum of N components is not larger than TOTN
# Check that the sum of P components is not larger than TOTP
#
# 3 functions for N sums:
# - 1: inorganic N given as sum, ammonium + inorganic N  
# - 2: inorganic N given as sum, ammonium + inorganic N + PON (particulate N)
# - 3: inorganic N given as NO2 + NO3 components, ammonium + inorganic N
#
# 2 functions for P sums:
# - 1: inorganic P (phosphate)  
# - 2: inorganic P (phosphate) + TOTP_P (particulate P)


check_sums_n1 <- function(data, max_n = 30){
  # TOTN vs NH4 + sum(NO3,NO2)
  # TOTN too small 2018-10-10 (V-2, VT-67) and 2018-11-13 (VT-66)
  df <- data %>%
    filter(Variable %in% c("TOTN", "NH4-N", "NO3+NO2-N") & !is.na(Value)) %>%
    select(StationCode, Time, Depth1, Variable, Value) %>%
    pivot_wider(names_from = Variable, values_from = Value) %>%
    mutate(Check = (TOTN - `NH4-N` - `NO3+NO2-N`)/TOTN*100) %>%      # Check = difference in % of TOTN
    filter(!is.na(Check))
  cat("======================================================================\n")
  cat("Check whether TotN is smaller or equal to ammonium + inorganic N (inorganic N given as sum)\n")
  cat("\nObservations per year:\n")
  table(year(df$Time)) %>% print()
  cat("\nTotN smaller than ammonium + sum(NO3,NO2) in", sum(df$Check < 0), "cases (", round(100*mean(df$Check < 0),1), "percent )\n\n")
  if (sum(df$Check < 0)){
    cat("Cases where total < sum are given in table\n")
    if (sum(df$Check < 0) > max_n)
      cat("Only first", max_n, "cases shown\n")
    df[df$Check < 0,] %>% as.data.frame() %>% head(max_n) %>% print() 
  } else {
    cat("Sum test OK\n\n")
  }
  invisible(df)
}

check_sums_n2 <- function(data, max_n = 30){
  
  # TOTN vs NH4 + sum(NO3,NO2) + PON
  # I.e., as above but also including PON
  # TOTN never too small
  df <- data %>%
    filter(Variable %in% c("TOTN", "NH4-N", "NO3+NO2-N", "PON") & !is.na(Value)) %>%
    select(StationCode, Time, Depth1, Variable, Value) %>%
    pivot_wider(names_from = Variable, values_from = Value) %>%
    mutate(Check = (TOTN - `NH4-N` - `NO3+NO2-N` - PON)/TOTN*100) %>%      # Check = difference in % of TOTN
    filter(!is.na(Check))
  cat("======================================================================\n")
  cat("Check whether TotN is smaller or equal to ammonium + inorganic N + PON (inorganic N given as sum)\n")
  cat("\nObservations per year:\n")
  table(year(df$Time)) %>% print()
  cat("\nTotN smaller than ammonium + sum(NO3,NO2) + PON in", sum(df$Check < 0), "cases (", round(100*mean(df$Check < 0),1), "percent )\n\n")
  if (sum(df$Check < 0)){
    cat("Cases where total < sum are given in table\n")
    if (sum(df$Check < 0) > max_n)
      cat("Only first", max_n, "cases shown\n")
    df[df$Check < 0,] %>% as.data.frame() %>% head(max_n) %>% print() 
  } else {
    cat("Sum test OK\n\n")
  }
  
  invisible(df)
}


check_sums_n3 <- function(data, max_n = 30){
  # TOTN vs NH4 + NO3 + NO2
  # TOTN not given for these years
  df <- data %>%
    filter(Variable %in% c("TOTN", "NH4-N", "NO2-N", "NO3-N") & !is.na(Value)) %>%
    select(StationCode, Time, Depth1, Variable, Value) %>%
    pivot_wider(names_from = Variable, values_from = Value) %>%
    mutate(Check = (TOTN - `NH4-N` - `NO2-N` - `NO3-N`)/TOTN*100) %>%      # Check = difference in % of TOTN
    filter(!is.na(Check))
  cat("======================================================================\n")
  cat("Check whether TotN is smaller or equal to ammonium + inorganic N (inorganic N given as components)\n")
  cat("\nObservations per year:\n")
  table(year(df$Time)) %>% print()
  cat("\nTotN smaller than ammonium + NO3 + NO2 in", sum(df$Check < 0), "cases (", round(100*mean(df$Check < 0),1), "percent )\n\n")
  if (sum(df$Check < 0)){
    cat("Cases where total < sum are given in table\n")
    if (sum(df$Check < 0) > max_n)
      cat("Only first", max_n, "cases shown\n")
    df[df$Check < 0,] %>% as.data.frame() %>% head(max_n) %>% print() 
  } else {
    cat("Sum test OK\n\n")
  }
  
  invisible(df)
  
}

# check_sums_n1(dat2)
# check_sums_n2(dat2)
# check_sums_n3(dat2)


check_sums_p1 <- function(data, max_n = 30){
  # TOTP vs PO3 + TOTP_P
  # TOTP too small in 63 cases (ca 4%)
  df <- data %>%
    filter(Variable %in% c("TOTP", "TOTP_P", "PO4-P") & !is.na(Value)) %>%
    select(StationCode, Time, Depth1, Variable, Value) %>%
    pivot_wider(names_from = Variable, values_from = Value) %>%
    mutate(Check = (TOTP - `TOTP_P` - `PO4-P`)/TOTP*100) %>%      # Check = difference in % of TOTN
    filter(!is.na(Check))
  cat("======================================================================\n")
  cat("Check whether TotP is smaller or equal to inorganic P + TOTP_P\n")
  cat("Observations per year:\n")
  table(year(df$Time)) %>% print()
  cat("TotP smaller than inorganic P + TOTP_P in", sum(df$Check < 0), "cases (", round(100*mean(df$Check < 0),1), "percent )\n\n")
  if (sum(df$Check < 0)){
    cat("Cases where total < sum are given in table\n")
    if (sum(df$Check < 0) > max_n)
      cat("Only first", max_n, "cases shown\n")
    df[df$Check < 0,] %>% as.data.frame() %>% head(max_n) %>% print() 
  } else {
    cat("Sum test OK\n\n")
  }
  
  invisible(df)
  
}
  
  # ggplot(df, aes(Check)) + geom_histogram()
  
  
check_sums_p2 <- function(data, max_n = 30){
  # TOTP vs PO3
  # TOTP too small in 23 cases (ca 4%)
  df <- data %>%
    filter(Variable %in% c("TOTP", "PO4-P") & !is.na(Value)) %>%
    select(StationCode, Time, Depth1, Variable, Value) %>%
    pivot_wider(names_from = Variable, values_from = Value) %>%
    mutate(Check = (TOTP - `PO4-P`)/TOTP*100) %>%      # Check = difference in % of TOTN
    filter(!is.na(Check))
  cat("======================================================================\n")
  cat("Check whether TotP is smaller or equal to inorganic P\n")
  cat("Observations per year:\n")
  table(year(df$Time)) %>% print()
  cat("TotP smaller than inorganic P in", sum(df$Check < 0), "cases (", round(100*mean(df$Check < 0),1), "percent )\n\n")
  if (sum(df$Check < 0)){
    cat("Cases where total < sum are given in table\n")
    if (sum(df$Check < 0) > max_n)
      cat("Only first", max_n, "cases shown\n")
    df[df$Check < 0,] %>% as.data.frame() %>% head(max_n) %>% print() 
  } else {
    cat("Sum test OK\n\n")
  }
  
  invisible(df)
  
  }


