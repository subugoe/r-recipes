#+ setup, include=FALSE
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE,
  echo = TRUE)
#' ## How many publishers have opened-up their references?
#' 
#' Question was asked by @rmounce
#' <https://github.com/ropensci/rcrossref/issues/158>
#' 
#' Let's implement Scott Chamberlain's solution
library(tidyverse)
library(knitr)
library(rcrossref)
#' ### Publisher that have not opened-up their references, yet
no_refs <- lapply(c(0, seq(1001,10000, by = 1000)), function(x) {
  offset <- x
  tt <- rcrossref::cr_members(filter = list(has_public_references = FALSE), limit = 1000, offset = offset)
  tt$data
})
no_refs_df <- bind_rows(no_refs) %>%
  select(1:6) %>%
  mutate(total.dois = as.numeric(total.dois)) %>%
  filter(current.dois > 0) %>%
  arrange(desc(total.dois))
#' tibble
no_refs_df
#' Top 10 nicely printed
no_refs_df %>%
  head(10) %>%
  knitr::kable()
#' Export data as csv
rio::export(no_refs_df, "no_public_refs.csv")
#' ### Publishers with open refeference
public_refs <- lapply(c(0, seq(1001,10000, by = 1000)), function(x) {
  offset <- x
  tt <- rcrossref::cr_members(filter = list(has_public_references = TRUE), limit = 1000, offset = offset)
  tt$data
})
public_refs_df <- bind_rows(public_refs) %>%
  select(1:6) %>%
  mutate(total.dois = as.numeric(total.dois)) %>%
  arrange(desc(total.dois))
#' tibble
public_refs_df
#' Top 10 nicely printed
public_refs_df %>%
  head(10) %>%
  knitr::kable()
#' Export data as csv
readr::write_csv(public_refs_df, "public_refs.csv")
