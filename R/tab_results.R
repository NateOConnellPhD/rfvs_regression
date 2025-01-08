tab_results <- function(df, df.ignore=NULL, rfvs.ignore=NULL){

 df <-  bench_standardize(df, df.ignore = df.ignore, rfvs.ignore=rfvs.ignore)

 #Label data
 df$overall$rfvs <- factor(df$overall$rfvs, rfvs_key[rfvs_key$rfvs_label %in% df$overall$rfvs,]$rfvs_label,
                           rfvs_key[rfvs_key$rfvs_label %in% df$overall$rfvs,]$figure_label)

 res_sum <- data.frame(Method=df$overall$rfvs,
                       stat  = rep(c("Mean (SD)<br>Median [IQR]"), 2),
                       rsq_axis = paste(round(df$overall$rsq_axis_mean,2), " (", round(df$overall$rsq_axis_se,3),")<br>",
                                        round(df$overall$rsq_axis_50,2), " [", round(df$overall$rsq_axis_25,3), ", ",round(df$overall$rsq_axis_75,3),"]"),
                       rsq_oblique = paste(round(df$overall$rsq_oblique_mean,2), " (", round(df$overall$rsq_oblique_se,3),")<br>",
                                           round(df$overall$rsq_oblique_50,2), " [", round(df$overall$rsq_oblique_25,3), ", ",round(df$overall$rsq_oblique_75,3),"]", sep=""),
                       pr = paste(round(df$overall$perc_reduced_mean,2), " (", round(df$overall$perc_reduced_se,3),")<br>",
                                  round(df$overall$perc_reduced_50,2), " [", round(df$overall$perc_reduced_25,3), ", ",round(df$overall$perc_reduced_75,3),"]"),
                       time = paste(round(df$overall$time_mean,2), " (", round(df$overall$time_se,3),")<br>",
                                    round(df$overall$time_50,2), " [", round(df$overall$time_25,3), ", ",round(df$overall$time_75,3),"]")

 )
 names(res_sum) <- c("Method","", "R-Squared (Axis)","R-Squared (Oblique)","Variable Percent Reduced","Time (seconds)")


 ## Label each method command
 # rs <- seq(from=1,to=14)
 # paste(paste("pack_rows(res_sum$Method[", rs, "],", rs, ",", rs,")", sep=""), collapse="%>%")

 res_sum[,-1] %>%  kbl("html", escape=F, fullwidth=F, align = "c") %>% kable_styling(position="center") %>%
  pack_rows(res_sum$Method[1],1,1, label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[2],2,2,label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[3],3,3,label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[4],4,4,label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[5],5,5,label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[6],6,6,label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[7],7,7,label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[8],8,8,label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[9],9,9,label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[10],10,10,label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[11],11,11,label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[12],12,12,label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[13],13,13,label_row_css = "border-bottom: 0px solid;")%>%
  pack_rows(res_sum$Method[14],14,14,label_row_css = "border-bottom: 0px solid;")

}




