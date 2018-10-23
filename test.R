source('workflow.R')

fs::dir_delete("modules")
git2r::clone("https://github.com/komparo/tde_dataset_dyntoy", local_path = "modules/dataset")
git2r::clone("https://github.com/komparo/tde_method_random", local_path = "modules/method")

source("modules/dataset/workflow.R")
source("modules/method/workflow.R")

datasets <- generate_dataset_calls(
  workflow_folder = "modules/dataset",
  datasets_folder = "results/datasets",
  dataset_design = dataset_design[1, ]
)

# datasets$start_and_wait()

methods <- generate_method_calls(
  datasets,
  workflow_folder = "modules/method",
  method_design = method_design[1, ],
  models_folder = "results/models"
)

# methods$start_and_wait()

metrics <- generate_metric_calls(
  methods,
  workflow_folder = ".",
  scores_folder = "results/scores",
  metric_design = metric_design[1, ]
)

# metrics$start_and_wait()

workflow <- workflow(
  list(
    datasets,
    methods,
    metrics
  )
)
workflow$run()
