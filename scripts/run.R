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
scores <- list(accuracy = parameters[["average_accuracy"]])

# write dataset
jsonlite::write_json(scores, outputs[["scores"]])
