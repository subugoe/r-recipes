#' ## Cleaning affiliations with Grid and Solr
#'
#' It is a common strategy to use research affiliations in scholarly articles to 
#' analyse research collaborations. Unfortunately, author addresses are often ambigue 
#' and require a lot of cleaning. To spend less time for curation, we use the
#' [Global Research Identifier Database (Grid)](https://www.digital-science.com/products/grid/)
#'  to identify institutions, and to gather cross-references as well as geo coordinates.
#'
#' In the following, it is described how you can use the most recent GRID data dump within R.
#'
#' ### Prerequisite: Run docker image
#'
#' GRID has no web API to access its data, but publishes open data dumps on a regular basis.
#' SUB has created an Docker container that buils a local Solr index with the most recent data dump
#' from the Global Research Identifier Database (Grid).
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
