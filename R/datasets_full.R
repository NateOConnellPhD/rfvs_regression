datasets_full <- function(data_cv, df.ignore=NULL){
 df <- read.csv("data/datasets_included.csv")
 df <- df[df$name %in% df.ignore ==F,]
 df <- merge(df, data_cv, by="name")
 df$np_ratio = 1/df$pn_ratio
 df
}
