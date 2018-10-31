library(readr)
library(dplyr)

# read parameters
parameters <- jsonlite::fromJSON(inputs[["parameters"]])
set.seed(parameters$seed)

# read expression
gene_expression <- read.csv(inputs[["gene_expression"]], row.names = 1) %>% as.matrix()

# read tde overall
dataset_tde_overall <- readr::read_csv(inputs[["dataset_tde_overall"]])
model_tde_overall <- readr::read_csv(inputs[["model_tde_overall"]])

# calculate accuracy
scores <- full_join(
  dataset_tde_overall %>% rename(significant_1 = significant),
  model_tde_overall %>% rename(significant_2 = significant)
) %>% 
  summarise(
    n = n(),
    TP = sum((significant_1 == significant_2) & significant_1),
    TN = sum((significant_1 == significant_2) & !significant_1),
    FP = sum((significant_1 == !significant_2) & !significant_1),
    FN = sum((significant_1 == !significant_2) & significant_1),
    P = sum(significant_1),
    N = sum(!significant_1),
    accuracy = (TP + TN) / n,
    balanced_accuracy = (TP / P + TN / N) /2,
    F1 = 2 * TP / (2 * TP + FP + FN)
  ) %>% 
  as.list()

# write dataset
jsonlite::write_json(scores, outputs[["scores"]])
