#' load wellcome data from https://doi.org/10.6084/m9.figshare.5639197.v2
library(tidyverse)
library(rcrossref)
wos <- readr::read_csv("wor.csv")
#' fetch dois from crossref
wellcome_df <- rcrossref::cr_works(filter = c(issn = "2398-502X"), 
                                   limit = 1000) %>%
  .$data
#' prepare unnest
names(wellcome_df$link) <- wellcome_df$DOI
#' unnest, remove unneded string, and export data
wellcome_dois <- dplyr::bind_rows(wellcome_df$link, .id = "doi") %>% 
  mutate(URL = gsub("/iparadigms", "", URL)) %>% 
  select(1:2)
wos <- inner_join(wellcome_dois, wos, by = c("URL" = "Article URL"))
readr::write_csv(wos, "wos_dois.csv")