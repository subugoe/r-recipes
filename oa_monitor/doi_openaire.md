


## Linking DOIs with OAI full-text links via openaire

### Motivation

Sometimes we not only want to retrieve one, but all open access copies of a publication by a DOI.
For this task, OpenAIRE is a very good choice. OpenAIRE links to all OAI versions rather than returning
only one open access source like oaDOI does. In comparision to BASE, OpenAIRE's main focus is on open access
full-texts and its API doesn’t require authentication!

API Documentation: http://api.openaire.eu/

### Helper functions

First, let's define the API functions

#### Request



```r
require(dplyr)
require(httr)
require(xml2)
openaire_doi_repo <- function(doi = NULL) {
  u <- httr::modify_url("http://api.openaire.eu/",
                        path = "search/publications",
                        query = list(doi = doi))
  resp <- httr::GET(u)
  if (httr::http_type(resp) != "application/xml") {
    stop("API did not return xml", call. = FALSE)
  }
  resp %>%
    httr::content() %>%
    parse_openaire_xml() %>%
    dplyr::mutate(doi = doi)
}
```

#### Parser


```r
parse_openaire_xml <- function(req) {
  xml2::xml_ns_strip(req)
  records <-
    xml2::xml_find_all(req,
                       ".//results//result//metadata//oaf:entity//oaf:result",
                       xml2::xml_ns(req))
  
  oai_id <- unlist(lapply(records, function(x)
    xml2::xml_find_all(x, "./originalId") %>%
      xml2::xml_text()))
  provenance_name <- unlist(lapply(records, function(x)
    xml2::xml_find_all(x, "./collectedfrom") %>%
      xml2::xml_attr("name")))
  dplyr::data_frame(oai_id, provenance_name)
}
```

### Request OAI identifiers by DOIs



```r
plyr::ldply(
  c(
    "10.1007/s00208-010-0630-3",
    "10.1186/s13068-016-0686-8",
    "10.7717/peerj.2323"
  ),
  openaire_doi_repo
) %>%
  dplyr::as_data_frame()
#> # A tibble: 7 × 3
#>                                                  oai_id
#>                                                   <chr>
#> 1                   oai:goedoc.uni-goettingen.de:1/7101
#> 2                               oai:arXiv.org:0907.0339
#> 3                  oai:goedoc.uni-goettingen.de:1/14067
#> 4                             oai:europepmc.org:4125152
#> 5 oai:doaj.org/article:53841a10ca214008ace6dfb90e3c0980
#> 6                      oai:pub.uni-bielefeld.de:2905071
#> 7                             oai:europepmc.org:3967570
#> # ... with 2 more variables: provenance_name <chr>, doi <chr>
```

