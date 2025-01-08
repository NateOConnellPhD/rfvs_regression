### plot dataset characteristics including number of predictors, number of observations, and CV
###     Input 'df' is dataframe titled datasets_included.csv from datasets_make


vis_datasets_smry <- function(df){

 #Create plot for Coef of Variation
 p1 <- ggplot(df, (aes(x = cv))) +
  geom_histogram(binwidth = 1,
                 color = "white",
                 fill = "black",boundary = 0) +
  ggtitle(expression(Coefficient ~ of ~ Variation ~
                      bgroup("(", frac(sigma, abs(mu)), ")") ~
                      Across ~ Outcomes)) +
  ylab("Frequency") +
  xlab("Coefficient of Variation") +
  theme_bw() +
  geom_hline(yintercept = 0) +
  scale_x_continuous(breaks = c(0, 1, 2, 3, 4, 5, 10, 15, 40, 50, 60, 70, 80)) +
  scale_x_break(breaks = c(15, 45), scales = .5) +
  theme(
   axis.text.x.top = element_blank(),
   axis.ticks.x.top = element_blank(),
   axis.line.x.top = element_blank()
  )

 #Plot for N:P
 p4 <- ggplot(df, aes(x = np_ratio)) +
  geom_histogram(binwidth = 25,
                 color = "white",
                 fill = "black", boundary = 0) +
  ggtitle("N:P Ratio Distribution") +
  ylab("Frequency") + xlab("N:P Ratio") +
  theme_bw() +
  geom_hline(yintercept = 0)

 #create plot for number of features
 p2 <- ggplot(df, aes(x = number.of.features)) +
  geom_histogram(binwidth = 25,
                 color = "white",
                 fill = "black",boundary = 0) +
  ggtitle("Number of Predictors") +
  ylab("Frequency") + xlab("Predictors") +
  theme_bw() +
  geom_hline(yintercept = 0)

 #Create plot for number of instances
 p3 <- ggplot(df, (aes(x = number.of.instances))) +
  geom_histogram(binwidth = 200,
                 color = "white",
                 fill = "black",boundary = 0) +
  ggtitle("Number of Observations") +
  ylab("Frequency") +
  xlab("Observations") +
  theme_bw() +
  geom_hline(yintercept = 0) +
  scale_x_continuous(breaks = c(0, 2000, 4000, 6000, 8000, 10000))

 #Create combined plot
 grid.arrange(p2, p3, print(p1), p4,
              layout_matrix = matrix(c(1, 2, 3, 4),
                                     ncol = 2,
                                     byrow = T))
}


