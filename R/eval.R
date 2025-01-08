


eval_rmse <- function(estimate, truth){

 sqrt( mean( (estimate - truth)^2 ) )

}


eval_rsq <- function(estimate, truth) {

 ss_total <- sum((truth - mean(truth))^2) # Total Sum of Squares

 ss_residual <- sum((truth - estimate)^2) # Residual Sum of Squares

 1 - (ss_residual / ss_total) # R² Formula

}



