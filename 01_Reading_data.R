
#
# Read and make som test plots
#

#
# Read data
#
library(readxl)
data <- read_excel("Some_data.xlsx")

#
# Test plots ----
#
plot(data$x)
plot(data$y)
plot(y ~ x, data)



