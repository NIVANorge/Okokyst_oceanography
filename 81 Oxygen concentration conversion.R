# Using 
library(marelac)

# ... as well as constants from
# http://www.ices.dk/marine-data/tools/Pages/Unit-conversions.aspx

x <- gas_O2sat(t = 15) # Saturation of O2 at 8 degrees C (given as mg/L)
x                                # Saturation concentration in mg/L  (9.43)
x*1000/molweight("O2")           # Saturation concentration in mmol/m3 (294.8)
x*1000/molweight("O2")*0.022391  # Saturation concentration in ml/m3 (6.60)
# or 
x*0.7                            # in ml/m3 (6.60) - from the ICES page

# Convert mg/L to saturation
temp <- 8
conc <- 6
conc/gas_O2sat(t = temp)*100       # saturation

# Convert ml/L to saturation
temp <- 8
conc <- 4
(conc/0.7)/gas_O2sat(t = temp)*100       # saturation

