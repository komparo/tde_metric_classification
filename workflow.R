library(certigo)

# installed together with certigo
library(tidyr)
library(stringr)
library(dplyr)

get_call <- function(models) {
  metric_design <- tibble(
    average_accuracy = c(0, 0.5, 1)
  ) %>% 
    mutate(parameters = dynutils::mapdf(., parameters)) %>% 
    mutate(id = as.character(seq_len(n())))
  
  design <- crossing(
    models$design %>% rename(method_id = id) %>% select(dataset_id, method_id, expression, tde_overall),
    metric_design
  ) %>% 
    mutate(
      script = list(script_file(str_glue("scripts/run.R"))),
      executor = list(docker_executor("komparo/tde_method_random")),
      accuracy = str_glue("{id}/{dataset_id}/{method_id}/accuracy.json") %>% purrr::map(derived_file)
  )
  
  rscript_call(
    design = design,
    inputs = c("script", "executor", "expression", "tde_overall", "parameters"),
    outputs = c("accuracy")
  )
}
