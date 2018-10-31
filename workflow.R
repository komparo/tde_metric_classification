library(certigo)
library(tde)

# installed together with certigo
library(tidyr)
library(stringr)
library(dplyr)

models$design %>% dynutils::mapdf(identity)

get_call <- function(models) {
  metric_design <- tibble(
      parameters = list(parameters(list(dummy = 0)))
    )
  
  design <- crossing(
    tibble(model = models$design %>% dynutils::mapdf(identity)),
    metric_design
  ) %>% 
    mutate(
      dataset_id = map_chr(model, ~.$dataset$id),
      method_id = map_chr(model, "method_id"),
      script = list(script_file(str_glue("scripts/run.R"))),
      executor = list(docker_executor("komparo/tde_method_random")),
      scores = str_glue("{id}/{dataset_id}/{method_id}/scores.json") %>% purrr::map(derived_file)
  )
  
  rscript_call(
    design = design,
    inputs = exprs(
      script, 
      executor, 
      gene_expression = map(model, ~.$dataset$gene_expression),
      dataset_tde_overall = map(model, ~.$dataset$tde_overall),
      model_tde_overall = map(model, "tde_overall"),
      parameters
    ),
    outputs = exprs(scores)
  )
}
