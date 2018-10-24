library(readr)
library(dplyr)

# read parameters
parameters <- jsonlite::fromJSON(inputs[["parameters"]])
set.seed(parameters$seed)

# read expression
expression <- read.csv(inputs[["expression"]], row.names = 1) %>% as.matrix()

# read tde overall
tde_overall <- readr::read_csv(inputs[["tde_overall"]])

# score
accuracy = rnorm(1, parameters[["average_accuracy"]], sd = 0.1)

# write dataset
jsonlite::write_json(accuracy, outputs[["accuracy"]])
