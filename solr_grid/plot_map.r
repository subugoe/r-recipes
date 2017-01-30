library(dplyr)
#' Load dataset with publications and GRIDs
grids <- readr::read_csv("grids.csv")
grids
#' Remove NA and `not_in_grid`
grids <-
  filter(grids,
         !is.na(grid_id_consolidated) &
           !grid_id_consolidated == "not_in_grid")
#' Get bipartite network, and calculate unipartite representation
grids_mat <- table(grids$grid_id_consolidated, grids$pub_id)
mat_t <- grids_mat %*% t(grids_mat)
#' convert to edge list using igraph library, we want a undirected network without loops (self-links)
my_net <- igraph::graph_from_adjacency_matrix(mat_t, mode = c("undirected"), diag = FALSE)
my_graph <- igraph::get.edgelist(my_net)
#' let's get geocodes using the Solr store. See also `solr_grid.r`
#' Call Solr API within R
library(solrium)
#' Connect
solrium::solr_connect("localhost:8983/solr/grid/select",
                      errors = "complete",
                      verbose = FALSE)
#' Call
my_graph_in <- plyr::ldply(my_graph[,1], function(x) solrium::solr_search(q = paste0("id:", x))) 
my_graph_out <- plyr::ldply(my_graph[,2], function(x) solrium::solr_search(q = paste0("id:", x)))
#' Remove missing geocodes
p1 <- my_graph_in %>% select(lng, lat) %>% filter(!is.na(lng))
p2 <- my_graph_out %>% select(lng, lat) %>% filter(!is.na(lng))
#' convert to numeric values
p1 <- sapply(p1, as.numeric) %>% dplyr::as_data_frame()
p2 <- sapply(p2, as.numeric) %>% dplyr::as_data_frame()
#' Get intermediate points (way points) between the two locations with longitude/latitude coordinates
arch <- geosphere::gcIntermediate(p1,
                       p2,
                       n=50,
                       breakAtDateLine=FALSE, 
                       addStartEnd=TRUE, 
                       sp=TRUE)

#' http://docs.ggplot2.org/0.9.3.1/fortify.map.html
arch_fortified <- plyr::ldply(arch@lines, ggplot2::fortify)
#' get world map
library(ggplot2)
library(ggmap)
library(sp)
library(grid)
library(geosphere)
world <- map_data("world")
world <- world[world$region != "Antarctica",] 

#' ggplot2 code
my_plot <- ggplot() +
  geom_map(data=world, map=world,
           aes(x=long, y=lat, map_id=region),
           color="#191919", fill="#7f7f7f", size=0.05, alpha=1/4) +
  geom_line(aes(long,lat,group=group), data=arch_fortified, alpha= 1/100 ,size=0.5, colour="skyblue1") +
  ggthemes::theme_map() +
  theme(strip.background = element_blank()) +
  theme(panel.background = element_rect(fill = "#01001C", colour=NA)) +
  theme(legend.position = "none") +
  geom_point(data = p1, aes(lng, lat), alpha = 1/100, size = 0.3, colour = "#B0E2FF") +
  geom_point(data = p2, aes(lng, lat), alpha = 1/100, size = 0.3, colour = "#B0E2FF") 
#' export
#+ fig.width=12, fig.height=6
my_plot
ggsave("network.pdf", width = 12, height = 6)

#' Europe and North America
#+ fig.width=12, fig.height=6

my_plot + coord_cartesian(xlim=c(-160,35),ylim=c(15,70))
ggsave("network_na_europe.pdf", width = 12, height = 6)
#' Links
#' - https://github.com/ricardo-bion/medium_visualization