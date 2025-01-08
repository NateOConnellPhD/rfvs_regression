# Filter out meats data from BM-Comb

bench_filter <- function(df, df.ignore){

 df <- df[df$dataset %in% df.ignore == F,]

}
