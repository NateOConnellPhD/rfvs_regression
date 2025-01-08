
# update target figurs and tables
tar_make_future(starts_with(c("fig", "tab")), workers=6, shortcut=T)

# Load Target figures and tables

tar_load(starts_with(c("fig", "results", "tab", "data")))
tar_load("bm_comb")

vis_datasets_smry(data_full)
table(data_full$number.of.features>150)


############################################################
################### Primary Results ########################
############################################################

### Export Datasets supplementary table

#write.csv(data_full[,c(1,2,12,13,14,15,16,17,18,20,23)], "supplement_datasets_table.csv", row.names = F)

######## Figures #################
#Dataset Characteristics Plot
fig1 = arrangeGrob(fig_datasets_smry)
ggsave(file='figures/figure1.tiff',plot=fig1, width=10, height=10, dpi=300)

#Table of results
tab_main

#Table for when no variables selected
tab_none_sel

#Computation Time Distributions
fig2 = arrangeGrob(fig_log_time, fig_log_time_z,
             layout_matrix=matrix(c(1,2), ncol=1, byrow=T))
ggsave(file='figures/figure2.tiff',plot=fig2, width=10, height=8, dpi=300)


#Computation Percetn Reduced distributions
fig3 = arrangeGrob(fig_perc_reduced, fig_perc_reduced_z,
             layout_matrix=matrix(c(1,2), ncol=1, byrow=T))
ggsave(file='figures/figure3.tiff',plot=fig3, width=10, height=8, dpi=300)


#Computation R-square Reduced distributions
fig4 = arrangeGrob(fig_rsq_axis, fig_rsq_z_axis,
             layout_matrix=matrix(c(1,2), ncol=1, byrow=T))
ggsave(file='figures/figure4.tiff',plot=fig4, width=10, height=8, dpi=300)


fig5 = arrangeGrob(fig_rsq_oblique, fig_rsq_z_oblique,
             layout_matrix=matrix(c(1,2), ncol=1, byrow=T))

ggsave(file='figures/figure5.tiff',plot=fig5, width=10, height=8, dpi=300)

#Figures Mean and Median Rsq
fig_rsq_median
fig_rsq_means

t1<- ggplot() +
 annotate("text", x = 4, y = 25, size=6,
          label = "Comparison of Mean R-Squared", color = "black", fontface="italic") +
 theme_void()

t2<- ggplot() +
 annotate("text", x = 4, y = 25, size=6,
          label = "Comparison of Median R-Squared", color = "black", fontface="italic") +
 theme_void()

fig6 = arrangeGrob(t1, fig_rsq_means, t2, fig_rsq_median,
             layout_matrix=matrix(c(1,2,2,2,2,3,4,4,4,4), ncol=1, byrow=T))
ggsave(file='figures/figure6.tiff',plot=fig6, width=8, height=12, dpi=300)


#Main Figure Median
fig7 = arrangeGrob(fig_main_median)
ggsave(file='figures/figure7.tiff',plot=fig7, width=11, height=13, dpi=300)

fig7new = arrangeGrob(fig_main_median2)
ggsave(file='figures/figure7new.tiff',plot=fig7new, width=9, height=13, dpi=300)

#Maing figure median complete case
fig8 = arrangeGrob(fig_main_median_cc)
ggsave(file='figures/figure8.tiff',plot=fig8, width=11, height=13, dpi=300)

fig8new = arrangeGrob(fig_main_median2_cc)
ggsave(file='figures/figure8new.tiff',plot=fig8new, width=9, height=13, dpi=300)


#Main figure Mean
grid.arrange(fig_main_mean)

#Main Figure Median - Complete Case
grid.arrange(fig_main_median_cc)

#Mean and Median; high and low
t1<- ggplot() +
 annotate("text", x = 4, y = 25, size=6,
          label = "N:P < 10", color = "black", fontface="italic") +
 theme_void()

t2<- ggplot() +
 annotate("text", x = 4, y = 25, size=6,
          label = "N:P \u2265 10", color = "black", fontface="italic") +
 theme_void()


fig9 = arrangeGrob(t1, fig_rsq_median_pn_high, t2, fig_rsq_median_pn_low,
             layout_matrix=matrix(c(1,2,2,2,2,2,3,4,4,4,4,4), ncol=1, byrow=T))

ggsave(file='figures/figure9.tiff',plot=fig9, width=8, height=12, dpi=300)


#Main Figure - PN High and low
grid.arrange(fig_main_median_axis_pn_high)
grid.arrange(fig_main_median_oblique_pn_high)

grid.arrange(fig_main_median_axis_pn_low)
grid.arrange(fig_main_median_oblique_pn_low)

######## Tables ################

#Table of no variables selected
tab_none_sel

#Table of overall results
tab_main




