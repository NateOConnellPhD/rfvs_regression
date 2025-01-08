## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

# needs to be run outside of tar_plan to avoid dynamic branching

# datasets_make(write_data = TRUE)


# if you don't need to update the tasks, just load them
datasets_included <- list.files('data', pattern = "-outcome-") %>%
 str_remove("\\.csv$")

# coordinate labels for variable selection methods in tables/figures
# (figures look nice when the labels include \n for vertical space)
rfvs_key <- tribble(
 ~ rfvs_label,      ~ table_label,        ~ figure_label,
 "alt",             "Altman",             "Altman",
 "anova",           "aorsf-Menze",              "aorsf -\nMenze",
 "aorsf",           "aorsf-Permutation",        "aorsf -\nPermutation",
 "boruta",          "Boruta",             "Boruta",
 "caret",           "CARET",              "CARET",
 "hap",             "rfvimptest",         "rfvimptest",
 "jiang",           "Jiang",              "Jiang",
 "mindepth_medium", "SRC",                "SRC",
 "negate",          "aorsf-Negation",           "aorsf -\nNegation",
 "none",            "None",               "None",
 "permute",         "Axis - SFE",         "Axis -\nSFE",
 "rrf",             "RRF",                "RRF",
 "svetnik",         "Svetnik",            "Svetnik",
 "vsurf",           "VSURF",              "VSURF"
)

# guides for running the benchmark experiment. Comment out methods seen
#  here to exclude them from the benchmark. Increase runs to add more
#  splits for each dataset.
analyses <- expand_grid(
 dataset = datasets_included,
 rfvs_label = c(
  'rfvs_none',
  'rfvs_permute',
  'rfvs_mindepth_medium',
  # 'rfvs_mindepth_high',
  # 'rfvs_mindepth_low',
  # 'rfvs_cif',
  'rfvs_jiang',
  'rfvs_vsurf',
  'rfvs_caret',
  'rfvs_rrf',
  'rfvs_hap',
  'rfvs_svetnik',
  'rfvs_boruta',
  "rfvs_alt",
  "rfvs_aorsf",
  "rfvs_negate",
  "rfvs_anova"
 ),
 run = 1:20
) %>%
 # filter(dataset %in% c("GeographicalOriginalofMusic-outcome-V100")) %>%
 separate(col = 'dataset',
          into = c('dataset', 'outcome'),
          sep = '-outcome-') %>%
 mutate(rfvs_fun = syms(rfvs_label),
        rfvs_label = str_remove(rfvs_label, '^rfvs_'))

branch_resources <-
 tar_resources(
  future = tar_resources_future(resources = list(n_cores=20))
 )

cols_to_summarize <- c("n_selected",
                       "perc_reduced",
                       "rsq_axis",
                       "rsq_oblique",
                       "time",
                       "log_time")

# Note: targets that start with the term 'datasets' require folder
#  'data/' created above using datasets_make().
tar_plan(

 # Dataset management ----

 # # cv = coefficient of variation
 # datasets = read_csv('data/datasets_included.csv') %>%
 #  left_join(datasets_amend(), by = 'name'),

 # Benchmark (i.e., bm) ----

 bm <- tar_map(
  values = analyses,
  names = c(dataset, outcome, rfvs_label, run),
  tar_target(
   bm,
   bench_rfvs(dataset = dataset,
              outcome = outcome,
              label = rfvs_label,
              rfvs = rfvs_fun,
              run = run,
              train_prop = .75),
   resources = branch_resources,
   memory = "transient",
   garbage_collection = TRUE
  )
 ),

 # stack benchmark results into one frame
 tar_combine(bm_comb, bm[[1]]),

 #### Create Summary Data Set Z-scores ####
 #results_z = bench_standardize(bm_comb, rfvs.ignore=NULL, df.ignore=c("meats_protein", "meats_water")),

 ###### Datasets summary ##########
 # requires folder 'data/' created above using datasets_make()
 data_amend = datasets_amend(), #calculates coefficient of variation of each data set
 data_full = datasets_full(data_amend, df.ignore=c("meats_water", "meats_protein")), #appends datasets_cv to datasets_selected and filters out duplicated meats data sets

 #dataset summary figure. Requires "grid.arrange(fig_datasets_smry)
 fig_datasets_smry = vis_datasets_smry(data_full),

 ####################################################################
 ####################### Full Data ##################################
 ####################################################################
 results = bench_filter(bm_comb, df.ignore=c("meats_water", "meats_protein")), #Get rid of extra meats data sets

 ###### Results Summary ##########
 # Distribution plots
 fig_log_time = vis_dist_plots(results, y="log_time", rfvs.ignore=c("none")),
 fig_log_time_z = vis_dist_plots(results, y="log_time_z",rfvs.ignore=c("none")),

 fig_perc_reduced = vis_dist_plots(results, y="perc_reduced",rfvs.ignore=c("none")),
 fig_perc_reduced_z = vis_dist_plots(results, y="perc_reduced_z",rfvs.ignore=c("none")),

 fig_rsq_axis = vis_dist_plots(results, y="rsq_axis"),
 fig_rsq_z_axis = vis_dist_plots(results, y="rsq_axis_z", rfvs.ignore="hap"),

 fig_rsq_oblique = vis_dist_plots(results, y="rsq_oblique"),
 fig_rsq_z_oblique = vis_dist_plots(results, y="rsq_oblique_z", rfvs.ignore="hap"),

 # Mean and Median R-square by Forest Type
 fig_rsq_median = vis_rsq(results, stat="median", rfvs.ignore = "hap"),
 fig_rsq_means = vis_rsq(results, stat="mean", rfvs.ignore="hap"),

 # Accuracy by time by Percent Reduction
 fig_main_median= vis_main_plot(results, x="rsq_50", y="time_50", z="perc_reduced_50", k_clust = 3),
 fig_main_mean= vis_main_plot(results, x="rsq_mean", y="time_mean", z="perc_reduced_mean"),

 # Accuracy by percent reduction by time
 fig_main_median2 = vis_main_plot2(results, x="rsq_50", y="perc_reduced_50", z="time_50"),
 fig_main_mean2 = vis_main_plot2(results, x="rsq_mean", y="perc_reduced_mean", z="time_mean"),

 ###### Generate tables of results #####
 #Main results plot
 tab_main = tab_results(results),

 #Methods in which no variables were selected
 tab_none_sel = tab_novar(results),

 ####################################################################
 ####################### Complete Case ##############################
 ####################################################################
 results_cc = bench_cc(results),

 ###### Results Summary ##########
 # Distribution plots
 fig_log_time_cc = vis_dist_plots(results_cc, y="log_time"),
 fig_log_time_z_cc = vis_dist_plots(results_cc, y="log_time_z"),

 fig_perc_reduced_cc = vis_dist_plots(results_cc, y="perc_reduced"),
 fig_perc_reduced_z_cc = vis_dist_plots(results_cc, y="perc_reduced_z"),

 fig_rsq_axis_cc = vis_dist_plots(results_cc, y="rsq_axis"),
 fig_rsq_z_axis_cc = vis_dist_plots(results_cc, y="rsq_axis_z", rfvs.ignore="hap"),

 fig_rsq_oblique_cc = vis_dist_plots(results_cc, y="rsq_oblique"),
 fig_rsq_z_oblique_cc = vis_dist_plots(results_cc, y="rsq_oblique_z", rfvs.ignore="hap"),

 # Mean and Median R-square by Forest Type
 fig_rsq_median_cc = vis_rsq(results_cc, stat="mean",rfvs.ignore = "hap"),
 fig_rsq_means_cc = vis_rsq(results_cc, stat="median",rfvs.ignore = "hap"),

 # Accuracy by time by Percent Reduction
 fig_main_median_cc = vis_main_plot(results_cc, x="rsq_50", y="time_50", z="perc_reduced_50"),
 fig_main_mean_cc = vis_main_plot(results_cc, x="rsq_mean", y="time_mean", z="perc_reduced_mean"),

 # Accuracy by percent reduction by time
 fig_main_median2_cc = vis_main_plot2(results_cc, x="rsq_50", y="perc_reduced_50", z="time_50"),
 fig_main_mean2_cc = vis_main_plot2(results_cc, x="rsq_mean", y="perc_reduced_mean", z="time_mean"),


 ###### Generate tables of results #####
 #Main results plot
 tab_main_cc = tab_results(results_cc),

 ####################################################################
 ####################### P/N > 0.10 ##############################
 ####################################################################
 results_pn_high = bench_filter(results, df.ignore=data_full[data_full$pn_ratio<0.1,]$name),

 ###### Results Summary ##########
 # Distribution plots
 fig_log_time_pn_high = vis_dist_plots(results_pn_high, y="log_time"),
 fig_log_time_z_pn_high = vis_dist_plots(results_pn_high, y="log_time_z"),

 fig_perc_reduced_pn_high = vis_dist_plots(results_pn_high, y="perc_reduced"),
 fig_perc_reduced_z_pn_high = vis_dist_plots(results_pn_high, y="perc_reduced_z"),

 fig_rsq_axis_pn_high = vis_dist_plots(results_pn_high, y="rsq_axis"),
 fig_rsq_z_axis_pn_high = vis_dist_plots(results_pn_high, y="rsq_axis_z", rfvs.ignore="hap"),

 fig_rsq_oblique_pn_high = vis_dist_plots(results_pn_high, y="rsq_oblique"),
 fig_rsq_z_oblique_pn_high = vis_dist_plots(results_pn_high, y="rsq_oblique_z", rfvs.ignore="hap"),

 # Mean and Median R-square by Forest Type
 fig_rsq_mean_pn_high = vis_rsq(results_pn_high, stat="mean",rfvs.ignore = "hap"),
 fig_rsq_median_pn_high = vis_rsq(results_pn_high, stat="median",rfvs.ignore = "hap"),

 # Apn_highuracy by time by Percent Reduction
 fig_main_median_pn_high = vis_main_plot(results_pn_high, x="rsq_50", y="time_50", z="perc_reduced_50"),
 fig_main_mean_pn_high = vis_main_plot(results_pn_high, x="rsq_mean", y="time_mean", z="perc_reduced_mean"),

 ###### Generate tables of results #####
 #Main results plot
 tab_main_pn_high = tab_results(results_pn_high),

 ####################################################################
 ####################### P/N <= 0.10 ##############################
 ####################################################################
 results_pn_low = bench_filter(results, df.ignore=data_full[data_full$pn_ratio>=0.1,]$name),

 ###### Results Summary ##########
 # Distribution plots
 fig_log_time_pn_low = vis_dist_plots(results_pn_low, y="log_time"),
 fig_log_time_z_pn_low = vis_dist_plots(results_pn_low, y="log_time_z"),

 fig_perc_reduced_pn_low = vis_dist_plots(results_pn_low, y="perc_reduced"),
 fig_perc_reduced_z_pn_low = vis_dist_plots(results_pn_low, y="perc_reduced_z"),

 fig_rsq_axis_pn_low = vis_dist_plots(results_pn_low, y="rsq_axis"),
 fig_rsq_z_axis_pn_low = vis_dist_plots(results_pn_low, y="rsq_axis_z", rfvs.ignore="hap"),

 fig_rsq_oblique_pn_low = vis_dist_plots(results_pn_low, y="rsq_oblique"),
 fig_rsq_z_oblique_pn_low = vis_dist_plots(results_pn_low, y="rsq_oblique_z", rfvs.ignore="hap"),

 # Mean and Median R-square by Forest Type
 fig_rsq_mean_pn_low = vis_rsq(results_pn_low, stat="mean",rfvs.ignore = "hap"),
 fig_rsq_median_pn_low = vis_rsq(results_pn_low, stat="median",rfvs.ignore = "hap"),

 # Apn_lowuracy by time by Percent Reduction
 fig_main_median_pn_low = vis_main_plot(results_pn_low, x="rsq_50", y="time_50", z="perc_reduced_50"),
 fig_main_mean_pn_low = vis_main_plot(results_pn_low, x="rsq_mean", y="time_mean", z="perc_reduced_mean"),

 ###### Generate tables of results #####
 #Main results plot
 tab_main_pn_low = tab_results(results_pn_low),

 ####################################################################
 ####################### All Numeric ##############################
 ####################################################################
 results_num = bench_filter(results, df.ignore=data_full[data_full$pred_ratio==1,]$name),

 ###### Results Summary ##########
 # Distribution plots
 fig_log_time_num = vis_dist_plots(results_num, y="log_time"),
 fig_log_time_z_num = vis_dist_plots(results_num, y="log_time_z"),

 fig_perc_reduced_num = vis_dist_plots(results_num, y="perc_reduced"),
 fig_perc_reduced_z_num = vis_dist_plots(results_num, y="perc_reduced_z"),

 fig_rsq_axis_num = vis_dist_plots(results_num, y="rsq_axis"),
 fig_rsq_z_axis_num = vis_dist_plots(results_num, y="rsq_axis_z", rfvs.ignore="hap"),

 fig_rsq_oblique_num = vis_dist_plots(results_num, y="rsq_oblique"),
 fig_rsq_z_oblique_num = vis_dist_plots(results_num, y="rsq_oblique_z", rfvs.ignore="hap"),

 # Mean and Median R-square by Forest Type
 fig_rsq_mean_num = vis_rsq(results_num, stat="mean",rfvs.ignore = "hap"),
 fig_rsq_median_num = vis_rsq(results_num, stat="median",rfvs.ignore = "hap"),

 # Anumuracy by time by Percent Reduction
 fig_main_median_num = vis_main_plot(results_num, x="rsq_50", y="time_50", z="perc_reduced_50"),
 fig_main_mean_num = vis_main_plot(results_num, x="rsq_mean", y="time_mean", z="perc_reduced_mean"),

 ###### Generate tables of results #####
 #Main results plot
 tab_main_num = tab_results(results_num),

 ####################################################################
 ####################### not all Numeric ##############################
 ####################################################################
 results_mixed = bench_filter(results, df.ignore=data_full[data_full$pred_ratio<1,]$name),

 ###### Results Summary ##########
 # Distribution plots
 fig_log_time_mixed = vis_dist_plots(results_mixed, y="log_time"),
 fig_log_time_z_mixed = vis_dist_plots(results_mixed, y="log_time_z"),

 fig_perc_reduced_mixed = vis_dist_plots(results_mixed, y="perc_reduced"),
 fig_perc_reduced_z_mixed = vis_dist_plots(results_mixed, y="perc_reduced_z"),

 fig_rsq_axis_mixed = vis_dist_plots(results_mixed, y="rsq_axis"),
 fig_rsq_z_axis_mixed = vis_dist_plots(results_mixed, y="rsq_axis_z", rfvs.ignore="hap"),

 fig_rsq_oblique_mixed = vis_dist_plots(results_mixed, y="rsq_oblique"),
 fig_rsq_z_oblique_mixed = vis_dist_plots(results_mixed, y="rsq_oblique_z", rfvs.ignore="hap"),

 # Mean and Median R-square by Forest Type
 fig_rsq_mean_mixed = vis_rsq(results_mixed, stat="mean",rfvs.ignore = "hap"),
 fig_rsq_median_mixed = vis_rsq(results_mixed, stat="median",rfvs.ignore = "hap"),

 # Amixeduracy by time by Percent Reduction
 fig_main_median_mixed = vis_main_plot(results_mixed, x="rsq_50", y="time_50", z="perc_reduced_50"),
 fig_main_mean_mixed = vis_main_plot(results_mixed, x="rsq_mean", y="time_mean", z="perc_reduced_mean"),


 ###### Generate tables of results #####
 #Main results plot
 tab_main_mixed = tab_results(results_mixed),

 ########################################################################
 ########################################################################
 tar_render(readme, "README.Rmd")


)



