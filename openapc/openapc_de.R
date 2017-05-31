#+ setup, include=FALSE
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE,
  echo = TRUE) 
#' ## Analyzing German spending on open access publication fees
#' Required libraries:
library(dplyr)
#' ### Create a map of financially supported open access articles per institution
#' Load mapping of Open APC institutions with GRID ids
institutions <- readr::read_csv("data/institutions.csv")
#' fetch lat/lon from sub goe docker container, 
#' see <https://github.com/subugoe/r-recipes/blob/master/solr_grid/solr_grid.md>
solrium::solr_connect("localhost:8983/solr/grid/select",
                      errors = "complete",
                      verbose = FALSE)
de_institutions <- institutions %>%
  filter(country == "DEU")
my_gc <- 
  plyr::ldply(de_institutions$grid, function(x)
    solrium::solr_search(q = paste0("id:", x))) %>%
  as_data_frame() 
my_gc
#' Merge with Open APC dataset
u <- "https://raw.githubusercontent.com/OpenAPC/openapc-de/79f20bd95f980e5974438f94cfc8cd51304c95ab/data/apc_de.csv"
apc_de <- readr::read_csv(u) %>%
  right_join(de_institutions, by = "institution") %>%
  right_join(my_gc, by = c("grid" = "id")) %>%
  mutate(lng = as.numeric(lng)) %>%
  mutate(lat = as.numeric(lat)) %>%
  # GRID wrongly places the Leibniz Foundation headquarter to beautiful Brandenburg, 
  # but there based in Berlin Mitte, so let's fix it
  mutate(lat = replace(lat, institution == "Leibniz-Fonds", 52.5306806)) %>%
  mutate(lng = replace(lng, institution == "Leibniz-Fonds", 13.3802093))

#' Prepare data frame for plotting
apc_to_plot <- apc_de %>%
  group_by(institution, lat, lng) %>%
  count(institution)
#' Plot
library(ggplot2)
library(ggmap)
library(scales)
my_map <- qmap("germany", zoom = 6, maptype = "toner-background", , darken = .7, source = "stamen")
my_map + 
  geom_point(data = apc_to_plot, aes(lng, lat, size = n), alpha = 30/100, fill = "gold", 
             shape = 21, color = "grey90") + 
  scale_size_continuous(range = c(1, 20)) + 
  theme(strip.background = element_blank()) +
  theme(legend.position = "none")

#' ### Analyze spending over fully and hybrid open access journals
apc_de %>% 
  group_by(is_hybrid) %>%
  count() %>%
  mutate(prop = round(n / sum(n) * 100, 2)) %>%
  knitr::kable()

#' ### Create a summary table institutional spending on articles published in open access journals
#' The following table summaries institutional spending on articles published in open access journals.
apc_de %>% 
  select(institution, euro) %>% 
  group_by(institution) %>% 
  ezsummary::ezsummary(n = TRUE , digits= 0, median = TRUE,
                       extra = c(
                         sum = "sum(., na.rm = TRUE)",
                         min = "min(., na.rm = TRUE)",
                         max = "max(., na.rm = TRUE)"
                       )) %>% 
  mutate(proportion = round(n / sum(n) * 100, 2)) %>% 
  ezsummary::ezmarkup('...[. (.)]..[. - .].') %>% 
  # format(big.mark=',') %>%
  # get rid of blanks in combination with big.mark
  mutate(`mean (sd)` = gsub("\\(  ", "(", .$`mean (sd)`)) %>% 
  select(institution, n, proportion, sum, `mean (sd)`, median, `min - max`) %>%
  arrange(desc(n)) %>%
  knitr::kable(col.names = c("Institution", "Articles", "Proportion", "Spending total (in €)", "Mean (SD)", "Median", "Minimum - Maximum"), align = c("l","r", "r", "r", "r", "r", "r"))
