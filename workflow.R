library(certigo)

# installed together with certigo
library(tidyr)
library(stringr)
library(dplyr)

metric_design_all <- tibble(
  average_accuracy = c(0, 0.5, 1)
) %>% 
  mutate(parameters = dynutils::mapdf(., parameters)) %>% 
  mutate(id = as.character(seq_len(n())))

generate_metric_calls <- function(methods, workflow_folder = ".", scores_folder = "scores", metric_design = metric_design_all) {
  design <- crossing(
    methods$design %>% rename(method_id = id) %>% bind_cols(methods$outputs) %>% select(-parameters),
    metric_design
  )
  
  rscript_call(
    "komparo/dummy",
    design = design,
    inputs = design %>% 
      select(expression, tde_overall, parameters) %>% 
      mutate(
        script = list(script_file(str_glue("{workflow_folder}/scripts/run.R"))),
        executor = list(docker_executor("komparo/tde_method_random"))
      ),
    outputs = design %>% transmute(
      accuracy = str_glue("{scores_folder}/{id}/{dataset_id}/{method_id}/accuracy.json") %>% purrr::map(derived_file)
    )
  )
}
