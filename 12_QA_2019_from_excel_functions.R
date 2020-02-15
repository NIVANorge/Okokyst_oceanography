#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# READING "WIDE" AQUAMONITOR DATA ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

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




#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# NUTRIENT PLOTS ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o


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

#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# NUTRIENT MEANS ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o


# Functions for getting weighted means for each nutrient/season
# By "weighted" we mean weighted over depth
#

#
# Weighted mean over depth, but for each time (and each station/variable)
#
# Weights are given by "depths_weights"
# "depths_weights" may be in 0-1 range, 0-100 or just as relative weights
#   (they are divided by the sum anyway)
#
NIVAklass_get_mean_overdepth <- function(years, data, vars, 
                                         months,
                                         depths = c(0,5,10),
                                         depths_weights = c(1,2,1)){
  lookuptable_weight <- 
    data.frame(Depth1 = depths,
               Weight = depths_weights/sum(depths_weights)
    )
  df <- data %>%
    mutate(Depth1 = ifelse(Depth1 == 0.5, 0, Depth1)) %>%
    filter(Variable %in% vars & 
             Depth1 %in% depths &
             month(Time) %in% months & year(Time) %in% years) %>% 
    left_join(lookuptable_weight, by = "Depth1")
  df %>%
    group_by(StationCode, Variable, Time) %>%
    summarize(Value = sum(Value*Weight)) %>%
    ungroup()
}

# Example
if (FALSE){
  df <- NIVAklass_get_mean_overdepth(
    years = 2017:2019,
    data = dat2,
    vars = c("TOTP", "PO4-P", "TOTN", "NO3+NO2-N", "NH4-N"),
    months = c(6,7,8))
  df
}
#
# Seasonal weighted means
# I.e., mean over depth and time (for each station/variable within a given season)
#
NIVAklass_get_meanvalues <- function(years, data, vars, 
                                     months, 
                                     depths = c(0,5,10),
                                     depths_weights = c(1,2,1)){
  df <- NIVAklass_get_mean_overdepth(years = years, 
                                     data = data, 
                                     vars = vars, 
                                     months = months, 
                                     depths = depths,
                                     depths_weights = depths_weights)
  
  df %>%
    group_by(StationCode, Variable) %>%
    summarize(Value = mean(Value)) %>%
    mutate(Variable = factor(Variable, levels = vars)) %>%
    arrange(Variable)
}

# Example
if (FALSE){
  # debugonce(NIVAklass_get_meanvalues)
  NIVAklass_get_meanvalues(
    years = 2017:2019,
    data = dat2,
    vars = c("TOTP", "PO4-P", "TOTN", "NO3+NO2-N", "NH4-N"),
    months = c(6,7,8)
  )
}

#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
# Functions for getting summer 
# and winter values of nutrients
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

# Total fosfor (μg P/l), vinter
# Fosfat-fosfor (μg P/l), vinter
# Total nitrogen (μg N/l), vinter
# Nitrat-nitrogen (μg N/l), vinter
# Ammonium-nitrogen (μg N/l), vinter


# Get summer values
NIVAklass_summervalues <- function(years, data, ...){
  NIVAklass_get_meanvalues(
    years = years, 
    data = data, 
    # Same order as in NIVAklass Excel sheet:
    vars = c("TOTP", "PO4-P", "TOTN", "NO3+NO2-N", "NH4-N"),
    months = c(6,7,8),
    ...
  )
}

# Get winter values
NIVAklass_wintervalues <- function(years, data, ...){
  NIVAklass_get_meanvalues(
    years = years, 
    data = data, 
    # Same order as in NIVAklass Excel sheet:
    vars = c("TOTP", "PO4-P", "TOTN", "NO3+NO2-N", "NH4-N"),
    months = c(1,2,12),
    ...
  )
}

# Get summer + winter values and combine them (row-wise)
NIVAklass_nutrientvalues <- function(years, data, ...){
  df_nut_summer <- NIVAklass_summervalues(years, data, ...) %>%
    mutate(Season = "Summer") %>%
    select(StationCode, Season, Variable, Value)
  df_nut_winter <- NIVAklass_wintervalues(years, data, ...) %>%
    mutate(Season = "Winter") %>%
    select(StationCode, Season, Variable, Value)
  bind_rows(df_nut_summer, df_nut_winter) %>%
    arrange(StationCode, Season, Variable)
}




#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# OXYGEN PLOTS ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

#
# For plotting time series, typically of oxygen
#
# data - must have variables Date, Category and one variable named in "variable"
#      - may optionally also have a variable named in "category_variable"
#       (Category can typically be "bottom" and "O2-minimum" by\ut can also be 
#        station code/name, or both)
# variable - typically Oksygen or Oksygenmetning
# category_variable - typically "Position"
# 
plot_ts <- function(data, 
                    years, 
                    time_limits = NULL,      # not necessary if years is given
                    y_variable = "Oksygen",
                    category_variable = NULL,  # gives 
                    quality_type = "Concentration",  # "Concentration", "Saturaion", or similar
                    quality_lines_y = NULL,   # can be used to override 'quality_type'
                    quality_labels_y = NULL,  # must be given if quality_lines_y is given
                    quality_labels = NULL,     # must be given if quality_lines_y is given
                    qualitylabel_x = -0.05,
                    title = NULL){ # 0 to 1; position of "SG", "G" etc.
  # Limits of x axis
  if (is.null(time_limits)){
    time_limits <- c(ymd(min(years)*10000 + 0101, tz = "GMT"),
                     ymd(max(years)*10000 + 1231, tz = "GMT"))
  }
  # For "winter shading":
  # the first winter starts from 10.01 the year before the first year  
  time_1oct = ymd(seq(min(years)-1, max(years))*10000 + 1001,  
                  tz = "GMT")
  # the last winter ends 30.04 the year after the last year  
  time_1may = ymd(seq(min(years), max(years)+1)*10000 + 0430, 
                  tz = "GMT")
  # Position 
  qualitylabel_coor <- as.POSIXct(
    as.numeric(time_limits[1]) + qualitylabel_x*diff(as.numeric(time_limits)), 
    origin = "1970-01-01", tz = "GMT"
  )
  time_limits
  # If quality_type = "Concentration" or something similar
  if (is.null(quality_lines_y)){
    if (grepl("conc", quality_type, ignore.case = TRUE)){
      quality_labels = c("SD","D","M","G","MG")
      quality_lines_y <- seq(1.5, 4.5, 1) 
      quality_labels_y <- seq(1, 5)
      # If quality_type = "Saturation" or simething similar
    } else if (grepl("sat", quality_type, ignore.case = TRUE)){
      quality_labels = c("SD","D","M","G","MG")
      quality_lines_y <- seq(20, 65, 15) 
      quality_labels_y <- seq(20 - 7.5, 65 + 7.5, 15)
    }
  }
  if (is.null(category_variable)){
    gg <- ggplot(dat_oxygen, aes(Date, .data[[y_variable]]))    
  } else {
    gg <- ggplot(dat_oxygen, aes(Date, .data[[y_variable]], 
                                 color = .data[[category_variable]]))    
  }
  gg <- gg + 
    # Winter shading
    annotate("rect", xmin = time_1oct, xmax = time_1may, 
             ymin = -Inf, ymax = Inf,
             alpha = .2) +
    # Main plot
    geom_line() +
    geom_point()
  # If quality_type is not "Concentration" or "Saturaion" AND 
  #   quality_lines_y is not given
  if (!is.null(quality_lines_y)){
    gg <- gg +
      geom_hline(yintercept = quality_lines_y, 
                 linetype = "dashed", color = "red3") +
      annotate("text", 
               x = qualitylabel_coor, 
               y = quality_labels_y, 
               label = quality_labels, 
               hjust = 0.5) #+
  }
  # coord_cartesian(xlim = time_limits)  
  gg <- gg + 
    labs(y = y_variable) + 
    theme_bw()
  if (!is.null(category_variable))
    gg <- gg +
    scale_color_discrete(category_variable)
  gg  
  }

# EXamples (for oxygen)
if (FALSE){
  plot_ts(dat_oxygen, 2017:2019, 
          y_variable = "Oksygen", category_variable = "Position", 
          quality_type = "Concentration")
  plot_ts(dat_oxygen, 2017:2019,  category_variable = "Position",
          y_variable = "Oksygenmetning", 
          quality_type = "Saturation")
}

#
# TESTS
#
# nutrient_plot_n("VT67", 0)
# nutrient_plot_p("VT3", 10)

#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# FUNCTIONS FOR CHECKING SUMS ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

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

# Check whether TotP is smaller or equal to phosphate + particular P (TOTP_P)   

check_sums_p1 <- function(data, 
                          max_n = 30){   # Max number of cases to show
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


# Check whether TotP is smaller or equal to phosphate     
check_sums_p2 <- function(data, 
                          max_n = 30){   # Max number of cases to show
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


