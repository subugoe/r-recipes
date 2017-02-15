#' ## Plotting Open APC data
#' <https://github.com/openapc/openapc-de>
#' Required libraries
library(dplyr)
library(ggplot2)
library(scales)
#' ## Load datasets from GitHub 
#' Get cost data from the Open APC initiatve
apc <- readr::read_csv("https://raw.githubusercontent.com/OpenAPC/openapc-de/f946f5c55e5335c3f2298be88507af94de45d585/data/apc_de.csv", col_names = TRUE)
#' Overview
apc
#' get insitution coding the OLAP server uses
inst <- readr::read_csv("https://raw.githubusercontent.com/OpenAPC/openapc-olap/master/static/institutions.csv", 
                        col_names = TRUE)
#'Overview
inst
#' merge datasets
apc <- apc %>%
  left_join(inst, by = "institution")
#' ## Plots
#' Plot a timeline without articles paid in 2017 grouped by hybrid / fully OA journals. 
#' Prepare the dataset first:
apc_time <- apc %>%
  group_by(period, is_hybrid, country) %>%
  summarize(articles = n()) %>%
  filter(period != 2017)
apc_time
#' Create the plot:
plot_time <- ggplot(apc_time, aes(period, articles, group = is_hybrid, fill = is_hybrid)) +
  geom_bar(stat="identity") +
  geom_col(position = position_stack(reverse = TRUE)) +
  xlab("Year") +
  ylab("Publications disclosed by Open APC initiative") +
  scale_y_continuous(breaks= pretty_breaks()) +
  scale_fill_manual("Is hybrid?", values = c("#3EA4D9", "grey75")) +
  theme_bw()
#+ fig.width=9, fig.height=4 
plot_time
#' Facet the plot by country
#+ fig.width=9, fig.height=4 
plot_time + facet_wrap(~country, ncol = 3)