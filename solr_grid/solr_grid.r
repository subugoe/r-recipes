#' ## Cleaning affiliations with GRID and Solr
#'
#' It is a common strategy to use research affiliations in scholarly articles to
#' analyse research collaborations. Unfortunately, author addresses are often ambigue
#' and require a lot of cleaning. To spend less time for data-curation, we use the
#' [Global Research Identifier Database (GRID)](https://www.digital-science.com/products/grid/)
#'  to identify institutions, and to gather cross-references as well as geo coordinates.
#'
#' In the following, it is described how you can use the most recent GRID data dump within R.
#'
#' ### Prerequisite: Run docker image
#'
#' GRID has no web API to access its data, but publishes open data dumps on a regular basis.
#' SUB has created an Docker container that builds a local Solr index with the most recent data dump
#' from the Global Research Identifier Database (GRID). So we can use Solr as a super fast local
#' store for GRID.
#'
#' Clone
#' - <https://github.com/subugoe/gro-solr_docker>
#'
#' and follow the instructions.
#'
#' ### Call Solr API within R
library(solrium)
#' #### Connect
solrium::solr_connect("localhost:8983/solr/grid/select",
                      errors = "complete",
                      verbose = FALSE)
#' #### Search
solrium::solr_search(q = '"University of Exeter"')
#' All orgs from Göttingen
solrium::solr_search(q = "city:Göttingen", rows = 100)
#' ### Retrieve geo-coordinates by GRID ID.

#' For this task, we will use a set of GRID IDs representing author affiliations. Affiliations were obtained 
#' from the Web of Science and semi-automatically matched with GRID IDs. Because of the Web of Science database 
#' licence, the Web of Science database identifier was anomized for this recipe.
#'
#' #### Load dataset with GRID IDs
#'
#' The dataset consist of two columns where `pub_id` represents publications and `grid_id_consolidated` affiliations (GRID ID)
grids <- readr::read_csv("grids.csv")
grids
#' Remove NA and `not_in_grid`
grids <-
  filter(grids,
         !is.na(grid_id_consolidated) &
           !grid_id_consolidated == "not_in_grid")
#' #### Call local Solr API
solrium::solr_search(q = 'id:grid.1006.7')
#' Apply over all rows and add pub_id
library(dplyr)
my_gc <-
  plyr::ldply(grids$grid_id_consolidated, function(x)
    solrium::solr_search(q = paste0("id:", x))) %>%
  as_data_frame() %>%
  mutate(pub_id = grids$pub_id)
my_gc
#'
#' Let's explore the dataset,
#'
#' Number of publications
length(unique(my_gc$pub_id))
#' Number of distinct insitutions
length(unique(my_gc$id))
#' Calculate the number of papers per affiliation. For this purpose, we need to be aware that we only
#' extracted affiliations on the level of institutions, and thus not included departments. Therefore,
#' let's only count the unique occurrence of an affiliation per paper, `pub_distinct`.
my_gc %>%
  group_by(name, id) %>%
  count(pub_distinct = n_distinct(pub_id)) %>%
  mutate(proportion = pub_distinct / n_distinct(my_gc$pub_id) * 100) %>%
  select(-n) %>%
  arrange(desc(pub_distinct)) %>%
  head(10) %>%
  knitr::kable()
#' ### Plot map
#'
#' Prepare local data frame including geo-coordinates
gc_df <- my_gc %>%
  distinct()
#' Prepare world map using ggplot2 and the [ggalt](https://github.com/hrbrmstr/ggalt)-package.
library(ggplot2)
library(ggalt)    # devtools::install_github("hrbrmstr/ggalt")

#' Choose world map
world <- map_data("world")
#' Remove Antarctica
world <- world %>%
  filter(region != "Antarctica")
#' Plot map with nice aesthetics like here https://rud.is/b/2015/12/28/world-map-panel-plots-with-ggplot2-2-0-ggalt/
gg <- ggplot()
gg <- gg + geom_map(
  data = world,
  map = world,
  aes(x = long, y = lat, map_id = region),
  color = "white",
  fill = "#7f7f7f",
  size = 0.05,
  alpha = 1 / 4
)
gg <- gg + geom_point(
  data = gc_df,
  aes(x = as.numeric(lng), y = as.numeric(lat)),
  size = 0.8,
  alpha = 0.1,
  color = "#3fb0ac"
)
gg <- gg + coord_proj("+proj=wintri") +
  theme_map() +
  theme(strip.background = element_blank()) +
  theme(legend.position = "none")
gg
