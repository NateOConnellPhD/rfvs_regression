#summarize no variables selected
# df: object bm_comb

tab_novar <- function(df){
 df$lab <- factor(df$rfvs, rfvs_key$rfvs_label, rfvs_key$table_label)
 no_var <- df %>% group_by(lab, dataset) %>%
  summarize(no_var = sum(none_selected==1)) %>%
  group_by(lab) %>% summarize(no_var_total=sum(no_var),
                               no_var_df = sum(no_var>0))
 names(no_var) <- c("Method", "Number of Times \nNo Variables Selected", "Number of Datasets \nnone selected at least once")

 no_var %>% kbl(caption="Frequency of No Variables Selected") %>%     kable_classic_2(full_width = F)
}



