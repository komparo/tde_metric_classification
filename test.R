pull_or_clone <- function(repo, local_path) {
  if (fs::dir_exists(local_path)) {
    git2r::pull(local_path)
  } else {
    git2r::clone(repo, local_path = local_path)
  }
}

pull_or_clone("https://github.com/komparo/tde_dataset_dyntoy", local_path = "modules/dataset")
pull_or_clone("https://github.com/komparo/tde_method_random", local_path = "modules/method")

source("modules/dataset/workflow.R")
datasets <- generate_dataset_calls(
  workflow_folder = "modules/dataset",
  datasets_folder = "data/datasets",
  dataset_design = dataset_design_all[1, ]
)

source("modules/method/workflow.R")
methods <- generate_method_calls(
  datasets,
  workflow_folder = "modules/method",
  method_design = method_design_all[1, ],
  models_folder = "data/models"
)

source('workflow.R')
metrics <- generate_metric_calls(
  methods,
  workflow_folder = ".",
  scores_folder = "data/scores",
  metric_design = metric_design_all[1, ]
)

workflow <- workflow(
  datasets,
  methods,
  metrics
)
workflow$reset()
workflow$run()

