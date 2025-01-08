
## Filters BM_comb data based on complete case analysis of datasets.
## Any dataset run with at least one method that failed to find variable is excluded for all datasets

bench_cc <- function(bm_comb){
 bm_comb %>% group_by(dataset, run) %>% mutate(exclude = sum(none_selected)) %>% dplyr::filter(exclude==0)
}




