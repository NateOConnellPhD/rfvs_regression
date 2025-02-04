
##Function creates z-scores for for each dataset across methods and iterations, and then averages them
# ignore is a vector of methods to ignore in computing z-scores
# Paramater Input:
#    bm_comb: raw bm_comb data that will be aggregated over
#    datasets_cv: include if you would like to filter results based on dataset Coefficeint of variation.
#    cv.thresh: vector of lower and upper boundaries for datasets CV to analyze
#    ignore: vector of methods to exclude. Relevant for standarized scores
#

bench_standardize <- function(bm_comb, datasets_cv=NULL, cv.thresh=NULL, rfvs.ignore=NULL,
                              df.ignore=NULL){

 #stores all method shortnames in vector for later labeling after exclusion
 all_rfvs <- levels(factor(bm_comb$rfvs))

 #exclude based on high cv
 if(is.null(cv.thresh)==F){
  bm_comb <- bm_comb[bm_comb$dataset %in% datasets_cv[datasets_cv$cv>cv.thresh[1] & datasets_cv$cv<cv.thresh[2] ,]$name,]
 }

 #exclude methods if specified
 if(is.null(rfvs.ignore)==F){
  bm_comb <- bm_comb[bm_comb$rfvs %in% rfvs.ignore==F,]
 }

 #exclude datasets
 if(is.null(df.ignore)==F){
  bm_comb <- bm_comb[bm_comb$dataset %in% df.ignore==F,]
 }

 #calculate percent variables reduced
 bm_comb <- bm_comb %>% mutate(perc_reduced = 1-n_selected/(n_col-1),
                               log_time = log(as.numeric(time)))

 #define columns to standardize
 z_cols <- c("rsq_axis", "rsq_oblique",
             "time","log_time", "perc_reduced")

 #standardize columns
 bm_comb <- bm_comb %>%
  group_by(dataset,run) %>% mutate(across(.cols = all_of(z_cols),
                                          .fns = list(z = ~scale(.x)[,1]))) %>% ungroup()
 bm_comb <- bm_comb %>%
  mutate(time = as.numeric(time, units = 'secs'))

 smry_by_rep <- bm_comb

 smry_cols <- c("n_selected",
                "perc_reduced",
                "rmse_axis",
                "rsq_axis",
                "rmse_oblique",
                "rsq_oblique",
                "time", "log_time",
                "rsq_axis_z", "rsq_oblique_z",
                "time_z","log_time_z", "perc_reduced_z")

 # summary for each dataset ----

 mean_se <- bm_comb %>%
  group_by(rfvs, dataset) %>%
  summarize(across(.cols = all_of(smry_cols),
                   .fns = list(mean = ~ mean(.x, na.rm = TRUE),
                               se = ~ sd(.x) / (length(.x) - 1))))

 quants <- bm_comb %>%
  reframe(
   across(
    .cols = c(n_selected, perc_reduced,
              rmse_axis, rsq_axis,
              rmse_oblique, rsq_oblique,
              time, log_time,
              rsq_axis_z, rsq_oblique_z,
              time_z,log_time_z, perc_reduced_z),
    .fns = ~ quantile(.x, probs = c(1,2,3) / 4, na.rm = TRUE)
   ),
   quantile = c(25, 50, 75),
   .by = c(rfvs, dataset)
  ) %>%
  pivot_wider(names_from = quantile,
              values_from = all_of(smry_cols))


 smry_by_data <- left_join(mean_se, quants)

 # smry_by_data %>%
 #  filter(!str_detect(string = dataset, pattern = 'meat')) %>%
 #  group_by(rfvs) %>%
 #  summarize(rsq_oblique = median(rsq_oblique_50)) %>%
 #  arrange(rsq_oblique)
 #
 # smry_by_data %>%
 #  filter(rfvs == 'anova') %>%
 #  select(dataset, rsq_oblique_50) %>%
 #  arrange(rsq_oblique_50) %>%
 #  View()

 # summary overall -----

 mean_se <- bm_comb %>%
  group_by(rfvs) %>%
  summarize(across(.cols = all_of(smry_cols),
                   .fns = list(mean = ~ mean(.x, na.rm = TRUE),
                               se = ~ sd(.x) / sqrt((length(.x) - 1)))))

 quants <- bm_comb %>%
  reframe(
   across(
    .cols = c(n_selected, perc_reduced,
              rmse_axis, rsq_axis,
              rmse_oblique, rsq_oblique,
              time, log_time,
              rsq_axis_z, rsq_oblique_z,
              time_z,log_time_z, perc_reduced_z),
    .fns = ~ quantile(.x, probs = c(1,2,3) / 4, na.rm = TRUE)
   ),
   quantile = c(25, 50, 75),
   .by = c(rfvs)
  ) %>%
  pivot_wider(names_from = quantile,
              values_from = all_of(smry_cols))

 smry_overall <- left_join(mean_se, quants) %>%
  mutate(dataset = 'overall', .after = rfvs)


 list(by_data = smry_by_data,
      overall = smry_overall,
      by_rep = smry_by_rep)
}
