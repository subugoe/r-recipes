#+ setup, include=FALSE
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE
)
#' # Task: Given a journal's ISSN, how do I find DOIs published in that jnl
#' in a given year with R?
#'
#' <https://twitter.com/StephenEglen/status/844201416478638081>
#'
#' **Solution**: Crosswalk [rcrossref](https://github.com/ropensci/rcrossref/),
#' a client for the DOI agency [Crossref](https://www.crossref.org/)
#' and [roadoi](https://github.com/njahn82/roadoi), an interface
#' to the [oaDOI.org linking service](https://oadoi.org/).
#' roadoi is only available from GitHub.
#'
#' ## Fetch DOIs from Crossref by ISSN
#'
#' ISSNs enable unique references to journals and can be easily
#' obtained from journal websites or library databases. As an example, we start
#' by fetching all works from the JASIST journal, which has the ISSN: 2330-1635.
#
library(dplyr)
my_jn_data <- rcrossref::cr_journals(
  "2330-1635",
  filter = c(from_pub_date = "2014-01-01", until_pub_date = "2014-12-31"),
  works = TRUE,
  limit = 1000
)
head(my_jn_data$data)
#' ## Call oaDOI.org
#'
#' In the next step, let's call oaDOI.org to explore whether there are OA copies
#'
oa_df <- roadoi::oadoi_fetch(dois = my_jn_data$data$DOI,
                             email = "najko.jahn@gmail.com")
#' ## Explore your data
#'
#' ### by evidence type
#'
oa_df %>%
  group_by(evidence) %>%
  summarise(Articles = n()) %>%
  mutate(Proportion = Articles / sum(Articles)) %>%
  arrange(desc(Articles))
#' ### by green or gold open access
oa_df %>%
  group_by(oa_color) %>%
  summarise(Articles = n()) %>%
  mutate(Proportion = Articles / sum(Articles)) %>%
  arrange(desc(Articles))
