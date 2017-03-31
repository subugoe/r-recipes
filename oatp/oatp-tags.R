#+ setup, include=FALSE
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE
)
#' ### Gathering Topis from the Open Access Tracking Project
#' Required Libraries
require(dplyr)
require(ggplot2)
require(httr)
require(jsonlite)
require(knitr)
#' Fetching the tags
u <- "http://tagteam.harvard.edu/hubs/oatp/items.json"
req <- httr::GET(u) %>%
  httr::content("text") %>%
  jsonlite::fromJSON()

tt <- plyr::ldply(1:100, function(x) {
  u <- paste0("http://tagteam.harvard.edu/hubs/oatp/items.json?page=", x)
  req <- httr::GET(u) %>%
    httr::content("text") %>%
    jsonlite::fromJSON()
  req$feed_items$tags
})
#' Summarize the data and exclude `oa.new`
count_data <- tt %>%
  unlist %>%
  as_data_frame() %>%
  group_by(value) %>%
  count(sort = TRUE) %>% 
  mutate(prop = n / sum(n)) %>%
  filter(!value == "oa.new")
#' Table
count_data %>% 
  head(20) %>%
  knitr::kable()
#' Bar chart
#+ fig.width=9, fig.height=4 
ggplot(count_data[1:20,], aes(reorder(value, n), n)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  xlab("oa-tags") +
  ylab("mentions")
