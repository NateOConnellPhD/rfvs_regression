#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param bm_comb
bench_clean <- function(bm_comb, cols_to_standardize = c("rsq_axis",
                                                         "rsq_oblique",
                                                         "time",
                                                         "log_time",
                                                         "perc_reduced")) {

 bm_comb %>%
  mutate(perc_reduced = 1 - n_selected / (n_col - 1),
         time = as.numeric(time, units = 'secs'),
         log_time = log(time)) %>%
  group_by(dataset, run) %>%
  mutate(across(.cols = all_of(cols_to_standardize),
                .fns = list(z = ~scale(.x)[,1]))) %>%
  ungroup()

}
