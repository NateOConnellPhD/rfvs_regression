


# Creates plot that shows R-Squared on x-axis, time on y-axis, and reduction percention as size and shade of points
# Input Paramaters:
#    df: should be list results
#    x: must be a measure of R-squared; either "rsq_50" or "rsq_mean"
#    y: either "perc_reduced_50" or "perc_reduced_mean"
#    z: must be measure of perent reduction: must be measure of time; either "time_mean", or "time_50"
#    k_clust: number of clusters to select

vis_main_plot2 <- function(df, x="rsq_50", y = "perc_reduced_50", z = "time_50",
                          rfvs.ignore=NULL, df.ignore=NULL){

 df <-  bench_standardize(df, df.ignore = df.ignore, rfvs.ignore=rfvs.ignore)
 df <- df$overall

 #set up label names
 #forest_type <- ifelse(grepl("axis", x)==T, " (Axis Forest)", " (Oblique Forest)")

 x_type <- ifelse(grepl("_z",x)==T, "Standardized ", "")
 x_lab <- ifelse(grepl("_z",x)==T, " Z-scores", "")
 x_stat <- ifelse(grepl("mean",x)==T, "Mean ", "Median ")

 y_type <- ifelse(grepl("_z",y)==T, "Standardized ", "")
 y_lab <- ifelse(grepl("_z",y)==T, " Z-scores", "")
 y_stat <- ifelse(grepl("mean",y)==T, "Mean ", "Median ")

 z_type <- ifelse(grepl("_z",z)==T, "Standardized ", "")
 z_lab <- ifelse(grepl("_z",z)==T, " Z-scores", "")
 z_stat <- ifelse(grepl("mean",z)==T, "Mean ", "Median ")


 grob_title <- paste0(x_type,x_stat, "Accuracy by ", y_type, y_stat, "Percent Reduction by ",
                      z_type,z_stat,
                      "Time")

 x_label <- ifelse(grepl("rsq", x), paste0("R-Squared", x_lab),
                   ifelse(grepl("time", x), paste0("Time (seconds)", y_lab), paste0("Percent \nReduction")))
 y_label <- ifelse(grepl("rsq", y), paste0("R-Squared", x_lab),
                   ifelse(grepl("time", y), paste0("Time (seconds)", y_lab), paste0("Percent \nReduction")))
 z_label <- ifelse(grepl("rsq", z), paste0("R-Squared", x_lab),
                   ifelse(grepl("time", z), paste0("Time (seconds)", y_lab), paste0("Percent \nReduction")))

 if(y_stat=="Median "){
  legend.pos <- c(0,0)
  legend.just <- c(-0.07,-.03)
 } else {
  legend.pos <- c(0,1)
  legend.just <- c(-0.07,1.03)
 }



 #Set up breaks and limits for z variable for downstream figure

  z_breaks <- seq(0,max(plyr::round_any(eval(parse(text=paste("df$",z,sep=""))),50, ceiling)), by=50)
  retain = NULL
  for(i in 1:(length(z_breaks)-1)){
   retain[i] = ifelse(sum(eval(parse(text=paste("df$",z,sep=""))) >= z_breaks[i] & eval(parse(text=paste("df$",z,sep=""))) < z_breaks[i+1])>0, T,F)
  }
  z_breaks = z_breaks[retain]
  z_lims <- c(0,max(z_breaks))

  round(eval(parse(text=paste("df$",z,sep=""))))
  if(z_type== "Standardized "){
   z_breaks <- seq(-3,1, by=1)
   z_lims <- c(-3,1)
  }

 #Label data
 df$lab <- factor(df$rfvs, rfvs_key[rfvs_key$rfvs_label %in% df$rfvs,]$rfvs_label,
                          rfvs_key[rfvs_key$rfvs_label %in% df$rfvs,]$figure_label)

 if(which(grepl("rsq", c(x,y,z)))==1){
  x = paste("rsq_axis_", ifelse(x_stat=="Median ", "50", "mean"), sep="")
 } else if(which(grepl("rsq", c(x,y,z)))==2){
  x = paste("rsq_axis_", ifelse(x_stat=="Median ", "50", "mean"), sep="")
 } else if(which(grepl("rsq", c(x,y,z)))==3){
  x = paste("rsq_axis_", ifelse(x_stat=="Median ", "50", "mean"), sep="")
 }

 if(which(grepl("rsq", c(x,y,z)))==1){
  x2 = paste("rsq_oblique_", ifelse(x_stat=="Median ", "50", "mean"), sep="")
 } else if(which(grepl("rsq", c(x,y,z)))==2){
  x2 = paste("rsq_oblique_", ifelse(x_stat=="Median ", "50", "mean"), sep="")
 } else if(which(grepl("rsq", c(x,y,z)))==3){
  x2 = paste("rsq_oblique_", ifelse(x_stat=="Median ", "50", "mean"), sep="")
 }


 axis_title <- ggplot() +
  annotate("text", x = 4, y = 25, size=6,
           label = "Axis Forests", color = "black", fontface="italic") +
  theme_void()

 ##################################

 lower_x = eval(parse(text=paste("min(df[df$rfvs!= 'hap',]$",x,")"))) - 0.02
 upper_x = eval(parse(text=paste("max(df[df$rfvs!= 'hap',]$",x,")"))) + 0.02

 lower_x2 = eval(parse(text=paste("min(df[df$rfvs!= 'hap',]$",x2,")"))) - 0.02
 upper_x2 = eval(parse(text=paste("max(df[df$rfvs!= 'hap',]$",x2,")"))) + 0.02


 lower_x = min(lower_x, lower_x2)
 upper_x = max(upper_x, upper_x2)

 #Panel A Plot
 p1a <- ggplot(df, aes(x=eval(parse(text=x)), y=eval(parse(text=y))))+
  geom_point(aes(size=eval(parse(text=z)), color=eval(parse(text=z))))+
  geom_text_repel(aes(label=lab),
                  force=10, max.overlaps = Inf, size=4, box.padding = 1.5,
                  min.segment.length = .5, segment.color = 'grey50') +
  scale_x_continuous(limits=c(lower_x, upper_x))+
  labs(x=x_label, y=y_label)+
  guides(color= guide_legend(title=z_label), size=guide_legend(title=z_label))+
  scale_size_continuous(limits=z_lims, breaks=z_breaks, range=c(2,15))+
  scale_color_continuous(limits=z_lims, breaks=z_breaks,
                         high = "#132B43", low = "#56B1F7")+
  theme(legend.position = "bottom") + guides(col=guide_legend(nrow=1, title=z_label),
                                             size = guide_legend(nrow=1, title=z_label))
 p1a

 legend <- ggpubr::get_legend(p1a)

 p1a <- p1a + theme(legend.position="none")


 #### Oblique K-Means ####
 if(which(grepl("rsq", c(x,y,z)))==1){
  x2 = paste("rsq_oblique_", ifelse(x_stat=="Median ", "50", "mean"), sep="")
 } else if(which(grepl("rsq", c(x,y,z)))==2){
  x2 = paste("rsq_oblique_", ifelse(x_stat=="Median ", "50", "mean"), sep="")
 } else if(which(grepl("rsq", c(x,y,z)))==3){
  x2 = paste("rsq_oblique_", ifelse(x_stat=="Median ", "50", "mean"), sep="")
 }

 ob_title <- ggplot() +
  annotate("text", x = 4, y = 25, size=6,
           label = "Oblique Forests", color = "black", fontface="italic") +
  theme_void()

 #Panel c Plot
 p1c <- ggplot(df, aes(x=eval(parse(text=x2)), y=eval(parse(text=y))))+
  geom_point(aes(size=eval(parse(text=z)), color=eval(parse(text=z))))+
  geom_text_repel(aes(label=lab),
                  force=10, max.overlaps = Inf, size=4, box.padding = 1.5,
                  min.segment.length = .5, segment.color = 'grey50') +
  scale_x_continuous(limits=c(lower_x, upper_x))+
  labs(x=x_label, y=y_label)+
  guides(color= guide_legend(title=z_label), size=guide_legend(title=z_label))+
  scale_size_continuous(limits=z_lims, breaks=z_breaks, range=c(2,15))+
  scale_color_continuous(limits=z_lims, breaks=z_breaks,
                         high = "#132B43", low = "#56B1F7")+
  theme(legend.position = "bottom") + guides(col=guide_legend(nrow=1, title=z_label),
                                             size = guide_legend(nrow=1, title=z_label))

 legend <- ggpubr::get_legend(p1c)

 p1c <- p1c + theme(legend.position="none")

 #Combine Plot
 grid.arrange(grobs=list(axis_title,
                         p1a,
                         ob_title,
                         p1c,
                         legend),
              layout_matrix = rbind(
               c(1, 1),

               c(2, 2),
               c(2, 2),
               c(2, 2),
               c(2, 2),
               c(2, 2),
               c(2, 2),
               c(2, 2),
               c(2, 2),
               c(2, 2),

               c(3, 3),

               c(4, 4),
               c(4, 4),
               c(4, 4),
               c(4, 4),
               c(4, 4),
               c(4, 4),
               c(4, 4),
               c(4, 4),
               c(4, 4),

               c(5, 5)),
              top = textGrob(grob_title,
                             gp=gpar(fontsize=15,font=3)))
}



