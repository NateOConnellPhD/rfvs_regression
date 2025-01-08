# calculate coefficient of variation across datasets
datasets_amend <- function(){

 df <- list.files('data', pattern = "-outcome-") %>%
  str_remove("\\.csv$")

 cv_list <- NULL

 for(i in 1:length(df)){

  temp_df <- read.csv(paste("data/", df[i], ".csv", sep=""))
  temp_df[sapply(temp_df, is.character)] = lapply(temp_df[sapply(temp_df, is.character)],
                                                  as.factor)

  cv_list[[i]] <- data.frame(
   name = gsub("(-outcome).*", "", df[i]),
   cv = abs(sd(temp_df$outcome, na.rm = T) / mean(temp_df$outcome, na.rm = T)),
   pn_ratio = (ncol(temp_df)-1)/nrow(temp_df),
   pred_ratio = ncol(temp_df %>% select(-outcome)  %>% select_if(is.numeric))/(ncol(temp_df %>% select(-outcome)  %>% select_if(is.factor))+ncol(temp_df %>% select(-outcome)  %>% select_if(is.numeric)))
)
 }

bind_rows(cv_list)


}

