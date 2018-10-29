library(certigo)

# installed together with certigo
library(tidyr)
library(stringr)
library(dplyr)

models$design %>% dynutils::mapdf(identity)

get_call <- function(models) {
  metric_design <- tibble(
    average_accuracy = c(0, 0.5, 1)
  ) %>% 
    mutate(
      parameters = dynutils::mapdf(., parameters),
      id = as.character(seq_len(n()))
    )
  
  design <- crossing(
    tibble(model = models$design %>% dynutils::mapdf(identity)),
    metric_design
  ) %>% 
    mutate(
      dataset_id = map_chr(model, ~.$dataset$id),
      method_id = map_chr(model, "id"),
      script = list(script_file(str_glue("scripts/run.R"))),
      executor = list(docker_executor("komparo/tde_method_random")),
      accuracy = str_glue("{id}/{dataset_id}/{method_id}/accuracy.json") %>% purrr::map(derived_file)
  )
  
  rscript_call(
    design = design,
    inputs = exprs(
      script, 
      executor, 
      dataset_expression = map(model, ~.$dataset$expression),
      dataset_tde_overall = map(model, ~.$dataset$tde_overall),
      model_tde_overall = map(model, "tde_overall"),
      parameters
    ),
    outputs = exprs(accuracy)
  )
}
