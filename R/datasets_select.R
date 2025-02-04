

#' Include/exclude datasets for the benchmark
#'
#' Each parameter corresponds to a dataset characteristic
#'
#' @param max_miss_prop maximum allowed proportion of missing values. Setting
#'   to zero (the default) means datasets with missing values are excluded.
#' @param min_features minimum allowed number of features.
#' @param max_features maximum allowed number of features.
#' @param min_obs minimum allowed number of observations.
#' @param max_obs maximum allowed number of observations.
#'
#' @return
#'  - data: data.table; openML dataset info
#'  - record: tibble; number of datasets excluded at each step

datasets_select <- function(max_miss_prop,
                            min_features,
                            max_features,
                            min_obs,
                            max_obs,
                            min_outcome_uni,
                            write_data) {

 dataset_record <- tibble(exclusion = character(), n = integer())

 datasets <- bind_rows(
  openml = as.data.table(listOMLDataSets()),
  modeldata = datasets_modeldata(),
  .id = 'source'
 )

 dataset_record <- dataset_record %>%
  add_row(
   exclusion = "Datasets available",
   n = nrow(datasets)
  )

 # include datasets that can be used in supervised regression tasks

 tasks <- as.data.table(listOMLTasks(task.type = "Supervised Regression"))

 datasets <- datasets %>%
  .[data.id %in% tasks$data.id | data.id < 0] %>%
  .[number.of.classes == 0]

 # this is a classification task dressed as a regression one
 datasets <- datasets[data.id != 301]

 dataset_record <- dataset_record %>%
  add_row(
   exclusion = "With 'Supervised Regression' task",
   n = nrow(datasets)
  )

 # missing data
 datasets[, miss_prop :=
           number.of.instances.with.missing.values /
           number.of.instances]

 datasets <- datasets[miss_prop <= max_miss_prop]

 dataset_record <- dataset_record %>%
  add_row(
   exclusion = paste0(
    "With <=", max_miss_prop * 100, "% missing observations"
   ),
   n = nrow(datasets)
  )

 # data dimension;
 datasets <- datasets[number.of.features >= min_features]

 dataset_record <- dataset_record %>%
  add_row(
   exclusion = as.character(
    glue("With number of features >= {min_features}")
   ),
   n = nrow(datasets)
  )

 datasets <- datasets[number.of.features <= max_features]

 dataset_record <- dataset_record %>%
  add_row(
   exclusion = as.character(
    glue("With number of features <= {max_features}")
   ),
   n = nrow(datasets)
  )

 datasets <- datasets[number.of.instances >= min_obs]

 dataset_record <- dataset_record %>%
  add_row(
   exclusion = as.character(
    glue("With number of observations >= {min_obs}")
   ),
   n = nrow(datasets)
  )

 datasets <- datasets[number.of.instances <= max_obs]

 dataset_record <- dataset_record %>%
  add_row(
   exclusion = as.character(
    glue("With number of observations <= {max_obs}")
   ),
   n = nrow(datasets)
  )

 # fri data are simulated.
 datasets <- datasets[!(str_detect(name, "^fri\\_"))]

 dataset_record <- dataset_record %>%
  add_row(
   exclusion = as.character(
    glue("Remove simulated data")
   ),
   n = nrow(datasets)
  )

 # use most recent version

 setkey(datasets, name, version)

 datasets <- datasets[datasets[, .I[.N], by = .(name)]$V1]

 dataset_record <- dataset_record %>%
  add_row(
   exclusion = as.character(
    glue("Remove redundant data versions (use most recent)")
   ),
   n = nrow(datasets)
  )

 datasets <- datasets[format != "Sparse_ARFF"]

 dataset_record <- dataset_record %>%
  add_row(
   exclusion = as.character(
    glue("Remove sparse ARFF data")
   ),
   n = nrow(datasets)
  )

 # kdd have many entries. Just use 1 to prevent them from having
 # too much influence on the overall results.

 kdd_did <- datasets$data.id[str_detect(datasets$name, "^kdd")]

 kdd_did_drop <- kdd_did[-1]
 kdd_rows_drop <- which(datasets$data.id %in% kdd_did_drop)

 datasets <- datasets[-kdd_rows_drop]

 # remove geographic_origin_of_music, but keep GeographicOriginOfMusic
 datasets <- datasets[data.id != 44965]

 # cpu_act and cpu_activity
 datasets <- datasets[data.id != 44978]

 # boston and boston_corrected (keep)
 datasets <- datasets[data.id != 531]

 # remove auto_price but keep AutoPrice
 datasets <- datasets[data.id != 207]

 dataset_record <- dataset_record %>%
  add_row(
   exclusion = as.character(
    glue("Remove overly similar datasets")
   ),
   n = nrow(datasets)
  )

 for(did in datasets$data.id){

  print(did)

  if(did < 0){

   data_name <- datasets[data.id == did, name]
   data <- get_modeldata(data_name)
   outcome <- get_modeldata_outcomes(data_name)

  } else {

   oml_data <- getOMLDataSet(data.id = did, verbosity = 0)

   data_name <- oml_data$desc$name

   data <- oml_data$data

   # use max of 1 outcome per dataset
   outcome <- tasks[data.id == did] %>%
    getElement('target.feature') %>%
    unique() %>%
    .[1]

  }

  if(!is_empty(outcome)){

   setDT(data)

   for(o in outcome){

    # for outcomes that start with a numeric, the variable name will
    # automatically be coerced to start with a letter, which is X
    if(str_detect(o, pattern = "^\\d")){
     o = paste0("X", o)
    }

    .n_uni <- length(unique(na.omit(data[[o]])))

    datasets[data.id == did, n_uni := .n_uni]

    # write one file per outcome
    # other outcome(s) can be used as a predictor for current one
    if( .n_uni >= min_outcome_uni ){

     setnames(data, old = o, new = 'outcome')

     fname <- paste0("data/", data_name, '-outcome-', o, '.csv')

     if(write_data){
      if(!file.exists(fname)) fwrite(data, fname)
     }

     # in case its a dataset with multiple outcomes
     setnames(data, old = 'outcome', new = o)

    }

   }

  }

 }

 datasets <- datasets[n_uni >= min_outcome_uni]

 dataset_record <- dataset_record %>%
  add_row(
   exclusion = as.character(
    table_glue("Remove data where outcome has < {min_outcome_uni} unique values")
   ),
   n = nrow(datasets)
  )

 list(data = datasets,
      record = dataset_record)

}


datasets_modeldata <- function(){

 data_list <- get_modeldata()

 map_dfr(
  data_list,
  .f = ~ {

   is.categorical <- function(x){
    is.factor(x) | is.character(x)
   }

   n_row_miss <- nrow(.x) - nrow(drop_na(.x))
   n_col_nmrc <- sum(sapply(.x, is.numeric))
   n_col_catg <- sum(sapply(.x, is.categorical))

   tibble(data.id = 0,
          version = 1,
          format = 'csv',
          number.of.classes = 0,
          number.of.features = ncol(.x)-1,
          number.of.instances = nrow(.x),
          number.of.instances.with.missing.values = n_row_miss,
          number.of.missing.values = sum(is.na(.x)),
          number.of.numeric.features = n_col_nmrc,
          number.of.symbolic.features = n_col_catg)

  },
  .id = 'name'
 ) %>%
  mutate(data.id = -1 * seq(n()))

}


get_modeldata <- function(.names = NULL){

  data_list <- list(

   Chicago = modeldata::Chicago %>%
    select(-date),

   car_prices = modeldata::car_prices %>%
    mutate(Price = log(Price)),

   check_times = modeldata::check_times %>%
    select(-package) %>%
    mutate(check_time = log(check_time)),

   chem_proc_yield = modeldata::chem_proc_yield,

   deliveries = modeldata::deliveries,

   hotel_rates = modeldata::hotel_rates %>%
    mutate(avg_price_per_room = log(avg_price_per_room)),

   meats_protein = modeldata::meats %>%
    select(-fat, -water),

   meats_fat = modeldata::meats %>%
    select(-protein, -water),

   meats_water = modeldata::meats %>%
    select(-fat, -protein),

   permeability_qsar = modeldata::permeability_qsar,

   stackoverflow = modeldata::stackoverflow,

   ames = modeldata::ames %>%
    mutate(Sale_Price = log(Sale_Price))

  )

 out <- data_list[.names %||% names(data_list)]

 if(length(out) == 1) return(out[[1]])

 out


}

get_modeldata_outcomes <- function(.names = NULL){

 outcomes <- c(
  Chicago = "ridership",
  car_prices = "Price",
  check_times = "check_time",
  chem_proc_yield = "yield",
  deliveries = "time_to_delivery",
  hotel_rates = "avg_price_per_room",
  meats_protein = "protein",
  meats_fat = "fat",
  meats_water = "water",
  permeability_qsar = "permeability",
  stackoverflow = "Salary",
  ames = "Sale_Price"
 )

 out <- outcomes[.names %||% names(outcomes)]

 if(length(out) == 1) return(out[[1]])

 out

}

