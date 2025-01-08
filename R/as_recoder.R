
as_tbl_recoder <- function(rfvs_key){

 as_recoder(select(rfvs_key, rfvs_label, table_label))

}

as_fig_recoder <- function(rfvs_key){

 as_recoder(select(rfvs_key, rfvs_label, figure_label))

}

as_recoder <- function(df){

 deframe(df)

}
