

#Plots distribution results
# input parameters:
#    df = "bm_comb"
#    y = name of metric to plot (e.g. time, log_time, time_z, rsq_axis, rsq_axis_z)
#    ignore = vector of rfvs methods to ignore; same as in bench_standardize

vis_dist_plots <- function(df, y="rsq_axis", rfvs.ignore=NULL,
                           df.ignore=NULL){

 df <- bench_standardize(df, df.ignore = df.ignore, rfvs.ignore=rfvs.ignore)

 #Define terms to name Plot title and y-axis based on variable assessed
 out_type <- case_when(
         grepl("rsq", y) ~ paste("R-Squared"),
         grepl("log_time", y) ~ paste("Log-Time"),
         grepl("time", y) ~ paste("Time"),
         grepl("perc_reduced",y) ~ paste("Percent Variable Reduction")
        )
 z_type <- ifelse(grepl("_z",y)==T, "Standardized ", "")
 z_lab <- ifelse(grepl("_z",y)==T, " Z-scores", "")
 forest_type <- ifelse(grepl("time", y)==T, "",
                       ifelse(grepl("perc_reduc",y)==T, "",
                              ifelse(grepl("axis", y)==T, " (Axis Forest)", " (Oblique Forest)")))
 main_title <- paste0("Method of Variable Selection by ", z_type, out_type, forest_type)
 y_label <- paste0(out_type, z_lab)

 #label
 df$overall$lab <- factor(df$overall$rfvs, rfvs_key[rfvs_key$rfvs_label %in% df$overall$rfvs,]$rfvs_label,
                          rfvs_key[rfvs_key$rfvs_label %in% df$overall$rfvs,]$figure_label)

 df$by_data$lab <- factor(df$by_data$rfvs, rfvs_key[rfvs_key$rfvs_label %in% df$by_data$rfvs,]$rfvs_label,
                          rfvs_key[rfvs_key$rfvs_label %in% df$by_data$rfvs,]$figure_label)

 df$by_rep$lab <- factor(df$by_rep$rfvs, rfvs_key[rfvs_key$rfvs_label %in% df$by_rep$rfvs,]$rfvs_label,
                          rfvs_key[rfvs_key$rfvs_label %in% df$by_rep$rfvs,]$figure_label)

 order_vars <- eval(parse(text=paste0("df$overall$",y,"_50")))

 if(grepl("time", y)){
  order_vars <- as.vector(df$overall$lab[order(order_vars)])
 } else {
  order_vars <-  as.vector(df$overall$lab[order(-order_vars)])
 }

   ggplot(df$by_rep, aes(x=lab, y=eval(parse(text=paste0(y)))))+geom_boxplot() +
    ggtitle(main_title) +  scale_x_discrete(limits=order_vars)+
    labs(x="", y=y_label)

}




