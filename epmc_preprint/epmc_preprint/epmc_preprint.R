#+ setup, include=FALSE
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE,
  echo = TRUE)
#' ### Proportion of Medline-indexed publications with preprint
library(europepmc)
library(tidyverse)
library(scales)
#' Obtain journal articles where also a preprint is indexed in Europe PMC
my_df <- europepmc::epmc_hits_trend("HAS_PREPRINT:Y", data_src = "med", period = 2015:2018)
#' Data
my_df
#' Plot
my_df %>%
  ggplot(aes(year, query_hits / all_hits)) +
  geom_line(color= "#30638E") +
  geom_point() +
  labs(x = "Year", 
       title = "Proportion of Medline-indexed publications with preprint",
       caption = "Data source: Europe PMC"
  ) +
  scale_y_continuous("", labels = scales::percent) +
  theme_minimal(base_family="Roboto", base_size = 14) +
  theme(plot.margin = margin(30, 30, 30, 30)) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.ticks = element_blank()) +
  theme(panel.border = element_blank())
