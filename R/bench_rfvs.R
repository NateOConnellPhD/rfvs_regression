#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param task
#' @param run
#' @param rfvs
#' @param tasks_included
bench_rfvs <- function(dataset,
                       outcome,
                       label,
                       rfvs,
                       run,
                       train_prop = NULL) {



 fname <- as.character(glue("data/{dataset}-outcome-{outcome}.csv"))

 data <- fread(fname)

 set.seed(run)

 if(ncol(data) > 150){

  subset_index <- names(data)[sample(ncol(data), 150, replace = FALSE)] %>%
   c("outcome") %>%
   unique()
  data <- select(data, all_of(subset_index))

 }

 if(is.null(train_prop)){

  if(nrow(data) > 2000){
   train_prop = 1000 / nrow(data)
  } else {
   train_prop <- 1/2
  }

 }

 split <- initial_split(data, prop = train_prop)

 formula <- outcome ~ .

 processor <- recipe(data, formula = formula) %>%
  # in case we allow missing values
  step_impute_mean(all_numeric_predictors()) %>%
  step_impute_mode(all_nominal_predictors()) %>%
  step_other(all_nominal_predictors(),
             threshold = 0.05,
             other = "other_recipe_cat") %>%
  # sparse factor protection
  step_novel(all_nominal_predictors()) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_lincomb(all_numeric_predictors()) %>%
  # cast integer 64 types to doubles
  step_mutate(across(everything(), as.numeric)) %>%
  step_nzv(all_predictors()) %>%
  prep(training = training(split))

 train <- juice(processor)
 test  <- bake(processor, new_data = testing(split))

 # select variables in training set

 start_time <- Sys.time()

 vars_selected <- try(
  rfvs(train = train, formula = formula)
 )

 if(is_error(vars_selected$vars)) browser()

 end_time <- Sys.time()

 fit_axis <- ranger(outcome ~ ., data = train[, vars_selected$vars])

 fit_oblique <- orsf(train[, vars_selected$vars], outcome ~ .)

 pred_axis <- fit_axis %>%
  predict(data = as.data.frame(test[, vars_selected$vars])) %>%
  getElement('predictions')

 pred_oblique <- fit_oblique %>%
  predict(new_data = as.data.frame(test[, vars_selected$vars])) %>%
  as.numeric()

 rsq_obi = eval_rsq(pred_oblique, test$outcome)
 rsq_axi = eval_rsq(pred_axis, test$outcome)

 tibble(
  dataset = dataset,
  outcome = outcome,
  rfvs = label,
  run = run,
  n_row = nrow(train),
  n_col = ncol(train),
  n_selected = length(vars_selected$vars) - 1,
  none_selected = vars_selected$no_var_sel,
  rmse_axis = eval_rmse(pred_axis, test$outcome),
  rsq_axis = eval_rsq(pred_axis, test$outcome),
  rmse_oblique = eval_rmse(pred_oblique, test$outcome),
  rsq_oblique = eval_rsq(pred_oblique, test$outcome),
  time = end_time - start_time
 )}
