
### Plots Rsquare for Axis and Olbique forests by Method
# df: is a bm_comb object containing all results
# stat: specified as either "mean" or "median"
# z_score: if T, plot standardized results
# rfvs.ignore: vector of methods to ignore for table; passes to bench standardize and effects computation of z-score
# df.ignore: vector of datasets to ignore; passes to bench_standardize

vis_rsq <- function(df, stat="mean", z_score=F, rfvs.ignore= NULL, df.ignore=NULL){

 df <- bench_standardize(df, df.ignore = df.ignore, rfvs.ignore=rfvs.ignore)

 rspec <- round_spec() %>%
  round_using_decimal(1)

 #Label data
 df$overall$rfvs <- factor(df$overall$rfvs, rfvs_key[rfvs_key$rfvs_label %in% df$overall$rfvs,]$rfvs_label,
                  rfvs_key[rfvs_key$rfvs_label %in% df$overall$rfvs,]$figure_label)

 y_label <- paste0("Prediction accuracy of downstream forest estimated ", stat," R-Squared")

 if(stat=="mean"){
  stat <- "_mean"
 } else if(stat=="median"){
  stat <- "_50"
 }


 if(z_score==F){
 data_gg <- df$overall %>%
  select(rfvs, matches(paste("^rsq.*", stat, "$", sep="")), -contains('_z_')) %>%
  pivot_longer(cols = -rfvs) %>%
  mutate(name = str_extract(name, pattern = "axis|oblique"),
         label = table_value(100 * value, rspec = rspec),
         rfvs = fct_reorder(rfvs, .x = value, .fun = max)) %>%
  group_by(rfvs) %>%
  mutate(hjust = if_else(value == max(value), -0.25, 1.25))
 } else if(z_score==T){
  data_gg <- df$overall %>%
   select(rfvs, matches(paste("^rsq.*", stat, "$", sep=""))) %>%
   select(rfvs, matches("_z_"))%>%
   pivot_longer(cols = -rfvs) %>%
   mutate(name = str_extract(name, pattern = "axis|oblique"),
          label = table_value(100 * value, rspec = rspec),
          rfvs = fct_reorder(rfvs, .x = value, .fun = max)) %>%
   group_by(rfvs) %>%
   mutate(hjust = if_else(value == max(value), -0.25, 1.25))
 }

 data_gg$name <- factor(data_gg$name, c("axis", "oblique"), c("Axis", "Oblique"))

 xlim <- c(min(data_gg$value)-.02, max(data_gg$value)+.02)

 ggplot(data_gg) +
  aes(x = rfvs, y = value, label = label, group = rfvs, color = name) +
  geom_line(color = 'grey50', alpha = 0.6) +
  geom_point() +
  geom_text(hjust = data_gg$hjust, show.legend = FALSE) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        legend.position = c(1,0), legend.justification = c(1.2,-0.2)) +
  coord_flip() +
  scale_y_continuous(limits= xlim, breaks=seq(from=floor(xlim[1]), to=ceiling(xlim[2]), .02), expand = c(0.01, 0.01)) +
  labs(x = "Variable selection method",
       y = y_label,
       color = "Forest type")

}


