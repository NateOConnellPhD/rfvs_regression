#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param train training data
#' @param formula model formula
#' @param ... not used
rfvs_none <- function(train, formula, ...) {



 list(vars =  names(train) %>% c("outcome") %>% unique(),
      no_var_sel = 0)

}

rfvs_aorsf <- function(train, formula, ...){


 fit <- orsf(formula = formula,
             data = train,
             importance = 'permute',
             no_fit = TRUE)

 data_vs <- orsf_vs(fit, n_predictor_min = 2)

 best_index <- which.max(data_vs$stat_value)

 list(vars = data_vs$predictors_included[best_index][[1]] %>% c("outcome"),
      no_var_sel = 0)

}

rfvs_negate <- function(train, formula, ...){


 fit <- orsf(formula = formula,
             data = train,
             importance = 'negate',
             no_fit = TRUE)

 data_vs <- orsf_vs(fit, n_predictor_min = 2)

 best_index <- which.max(data_vs$stat_value)


 list(vars = data_vs$predictors_included[best_index][[1]]%>% c("outcome"),
      no_var_sel = 0)


}

rfvs_anova <- function(train, formula, ...){


 fit <- orsf(formula = formula,
             data = train,
             importance = 'anova',
             no_fit = TRUE)

 data_vs <- orsf_vs(fit, n_predictor_min = 2)

 best_index <- which.max(data_vs$stat_value)

 list(vars =  data_vs$predictors_included[best_index][[1]]%>% c("outcome"),
      no_var_sel = 0)

}


rfvs_vsurf <- function(train, formula, ...) {

 x <- as.matrix(select(train, -outcome))
 y <- as.matrix(select(train, outcome))

 vi <- suppressWarnings(VSURF(x = x, y = y))

 out <- colnames(x)[vi$varselect.pred]

 if(is_empty(out)){
   vars_perm <- rfvs_permute(train, formula)
   list(vars = vars_perm$vars,
        no_var_sel = 1)

 }else{

 list(vars = out %>% c("outcome"),
      no_var_sel = 0)
 }

}


rfvs_hap <- function(train, formula, ...){

 vi <- rfvimptest(data = train,
                  yname = 'outcome',
                  type = 'SAPT',
                  progressbar = FALSE)

 if(all(vi$testres == 'keep H0')){
   list(vars = names(sort(vi$varimp, decreasing = TRUE))[1] %>% c("outcome"),
        no_var_sel = 1)
 }else{
 list(vars = names(vi$testres)[vi$testres == 'accept H1']%>% c("outcome"),
      no_var_sel = 0)
 }
}


rfvs_permute <- function(train, formula, ...) {

 fit <- ranger(formula = formula,
               data = train,
               importance = 'permutation')

 vi <- fit$variable.importance

 if(all(vi <= 0)){
  return(
   vi %>%
    sort(decreasing = TRUE) %>%
    names() %>%
    getElement(1)
  )
 }

 list(vars = names(vi)[vi > 0] %>% c("outcome"),
      no_var_sel = 0)

}


rfvs_cif <- function(train, formula, ...) {

 fit <- cforest(formula = formula, data = train)

 vi <- varimp(fit, conditional = TRUE)

 if(all(vi <= 0)){
  return(
   vi %>%
    sort(decreasing = TRUE) %>%
    names() %>%
    getElement(1)
  )
 }



 list(vars =  names(vi)[vi > 0]  %>% c("outcome"),
      no_var_sel = 0)

}

rfvs_mindepth <- function(train,
                          formula,
                          conservative,
                          ...){

 vi <- var.select.rfsrc(formula = formula,
                        data = as.data.frame(train),
                        method = 'md',
                        conservative = conservative,
                        verbose = FALSE)


 list(vars =   vi$topvars  %>% c("outcome"),
      no_var_sel = 0)

}

rfvs_mindepth_low <- function(train, formula, ...){
 rfvs_mindepth(train, formula, conservative = 'low')
}
rfvs_mindepth_medium <- function(train, formula, ...){
 rfvs_mindepth(train, formula, conservative = 'medium')
}
rfvs_mindepth_high <- function(train, formula, ...){
 rfvs_mindepth(train, formula, conservative = 'high')
}

rfvs_jiang <- function(train,
                       formula,
                       recompute = TRUE,
                       ntree = 500,
                       type = 'min', # can be 'min' or '1se'
                       ...){

 n_predictors <- ncol(train) - 1

 mtry <- ceiling(sqrt(n_predictors))

 forest <- cforest(formula = formula,
                   data = train,
                   controls = cforest_unbiased(mtry = mtry, ntree = ntree))

 # a list that contains the sequence of selected variables
 selections <- list()

 selections[[n_predictors]] <- varimp(forest, pre1.0_0 = T) %>%
  sort(decreasing = TRUE) %>%
  names()

 errors <- c()

 outcome_colname <- paste(formula)[2]

 y <- train[[outcome_colname]]

 # take backward rejection steps
 for (i in seq(n_predictors, 1)) {

  # set mtry to sqrt() of remaining variables
  mtry <- ceiling(sqrt(i))

  formula_recurse <- paste(selections[[i]], collapse = " + ") %>%
   paste(outcome_colname, ., sep = ' ~ ') %>%
   as.formula()

  forest <- cforest(formula = formula_recurse,
                    data = train,
                    controls = cforest_unbiased(mtry = mtry, ntree = ntree))

  errors[i] <- forest %>%
   predict(OOB = TRUE) %>%
   eval_rmse(truth = y)

  # define the next set of variables
  if (!recompute & i > 1) selections[[i - 1]] <- selections[[i]][-i]

  if (recompute & i > 1){
   selections[[i - 1]] <- try(varimp(forest, pre1.0_0 = T) %>%
                               sort(decreasing = T) %>%
                               names() %>%
                               .[-i])
  }

 }

 # compute the error expected when no predictor is used at all
 no_pred_error <- eval_rmse(estimate = mean(y), truth = y)

 errors <- c(no_pred_error, errors)

 # define the number of variables determined by the 0 s.e. and 1 s.e. rule
 n_optim <- switch(
  type,
  'min' = which.min(errors),
  '1se' = which(errors <= min(errors) + sd(errors)/sqrt(length(errors)))[1]
 )

 # subtract 1 because the errors have an additional value at the beginning
 output <- selections[[max(n_optim - 1, 1)]]

 list(vars =  output %>% c("outcome"),
      no_var_sel = 0)


}

rfvs_svetnik <- function(train,
                         formula,
                         ntree = 100,
                         folds = 5,
                         repetitions = 20,
                         ...){

 mtry <- ceiling(sqrt(ncol(train)-1)) # automatically set mtry to sqrt(p)

 forest <- cforest(outcome ~ .,
                   data = train,
                   # fit a forest
                   controls = cforest_unbiased(mtry = mtry, ntree = ntree))
 final.imps <-
  names(sort(varimp(forest, pre1.0_0 = T), decreasing = T)) # the final sequence

 errors <- array(NA, dim = c(repetitions, ncol(train), folds))

 for (x in 1:repetitions) {

  samps <- sample(rep(1:folds, length = nrow(train)))

  # cross validation
  for (k in seq(folds)) {

   .train <- train[samps != k,]
   .test <- train[samps == k,]

   forest <- cforest(outcome ~ .,
                     data = .train,
                     controls = cforest_unbiased(mtry = mtry, ntree = ntree))

   selection <- names(sort(varimp(forest, pre1.0_0 = T), decreasing = T))

   # do backward rejection steps
   for (i in seq(length(selection), 1)) {

    mtry <- min(mtry, ceiling(sqrt(i)))

    f_backward <- paste(
     "outcome", paste(selection[1:i], collapse = " + "), sep = " ~ "
    )

    forest <-
     cforest(
      formula = as.formula(f_backward),
      data = .train,
      controls = cforest_unbiased(mtry = mtry, ntree = ntree)
     )

    errors[x, i + 1, k] <-
     mean((.test$outcome - predict(forest, newdata = .test)) ^ 2)

   }
   errors[x, 1, k] <- mean((.test$outcome - mean(.train$outcome)) ^ 2)
  }
 }

 mean.errors <- sapply(seq(ncol(train)), function(x) mean(errors[, x,]))

 # optimal number of variables
 optimum.number <- which.min(mean.errors)

 if (optimum.number == 1) {

 list(vars =   final.imps[1]  %>% c("outcome"),
       no_var_sel = 0)
 } else{

 list(vars =   final.imps[seq(optimum.number-1)]  %>% c("outcome"),
      no_var_sel = 0)
 }

}



### RRF regularized RF
rfvs_rrf <- function(train, formula, ...){

 yvar <- as.character(formula[[2]])

 y <- train[[yvar]]
 x <- train %>%
  select(-all_of(yvar)) %>%
  as.matrix()

 rrf<- RRF(x=x, y=y)

 list(vars =   colnames(x)[rrf$feaSet]  %>% c("outcome"),
      no_var_sel = 0)

}

### Caret package/recursive feature elimination
rfvs_caret <- function(train, formula, ...){

 yvar <- as.character(formula[[2]])

 y <- train[[yvar]]
 x <- train %>%
  select(-all_of(yvar)) %>%
  as.matrix()


 caret <- rfe(x = x, y = y,
              sizes = seq(from = 1, to = ncol(x), by = 1),
              rfeControl = rfeControl(functions = rfFuncs))


 list(vars =   predictors(caret)  %>% c("outcome"),
      no_var_sel = 0)

}

rfvs_boruta <- function(train, formula,...){

 boruta <- Boruta::Boruta(formula, data = train)

 confirmed <- which(boruta$finalDecision == 'Confirmed')
 tentative <- which(boruta$finalDecision == "Tentative")

 if(!is_empty(confirmed)){
  return(list(vars =   names(boruta$finalDecision)[confirmed]  %>% c("outcome"),
       no_var_sel = 0))
 } else  if(!is_empty(tentative)){
  return(list(vars =   names(boruta$finalDecision)[tentative]  %>% c("outcome"),
       no_var_sel = 0))
 } else{
  # if it rejects everything, use standard importance to pick just 1
  vars_perm <- rfvs_permute(train, formula)
  list(vars = vars_perm$vars,
       no_var_sel = 1)
 }

}

rfvs_alt <- function(train, formula, ...){

 fit <- randomForest(formula, train, importance = TRUE)

 yvar <- as.character(formula[[2]])

 y <- train[[yvar]]
 x <- train %>%
  select(-all_of(yvar)) %>%
  as.matrix()

 pvals <- PimpTest(PIMP(x, y, fit))

 out <- rownames(pvals$pvalue)[pvals$pvalue < 0.05]

 if(is_empty(out)){
  out <- rownames(pvals$pvalue)[which.min(pvals$pvalue)]
  list(vars =   out  %>% c("outcome"),
       no_var_sel = 1)
 }else{
  list(vars =   out  %>% c("outcome"),
       no_var_sel = 0)
 }

}


