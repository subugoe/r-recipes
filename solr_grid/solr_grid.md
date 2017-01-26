## Cleaning affiliations with Grid and Solr

It is a common strategy to use research affiliations in scholarly articles to 
analyse research collaborations. Unfortunately, author addresses are often ambigue 
and require a lot of cleaning. To spend less time for curation, we use the
[Global Research Identifier Database (Grid)](https://www.digital-science.com/products/grid/)
 to identify institutions, and to gather cross-references as well as geo coordinates.

In the following, it is described how you can use the most recent GRID data dump within R.

### Prerequisite: Run docker image

GRID has no web API to access its data, but publishes open data dumps on a regular basis.
SUB has created an Docker container that buils a local Solr index with the most recent data dump
from the Global Research Identifier Database (Grid).

Clone
- <https://github.com/subugoe/gro-solr_docker>

and follow the instructions.

### Call Solr API within R


```r
library(solrium)
```

#### Connect


```r
solrium::solr_connect("localhost:8983/solr/grid/select",
                      errors = "complete",
                      verbose = FALSE)
```

```
## <solr_connection>
##   url:    http://localhost:8983/solr/grid/select
##   errors: complete
##   verbose: FALSE
##   proxy:
```

#### Search


```r
solrium::solr_search(q = '"University of Exeter"')
```

```
## # A tibble: 4 × 21
##                                          name
##                                         <chr>
## 1                        University of Exeter
## 2                          Derriford Hospital
## 3             Royal Devon and Exeter Hospital
## 4 Peninsula College of Medicine and Dentistry
## # ... with 20 more variables: wikipedia_url <chr>, links <chr>,
## #   types <chr>, lat <chr>, lng <chr>, city <chr>, country <chr>,
## #   country_code <chr>, geonames_id <chr>, id <chr>, status <chr>,
## #   established <int>, relationship <chr>, relationship_id <chr>,
## #   ISNI <chr>, FundRef <chr>, OrgRef <chr>, Wikidata <chr>,
## #   `_version_` <dbl>, acronyms <chr>
```

All orgs from Göttingen


```r
solrium::solr_search(q = "city:Göttingen", rows = 100)
```

```
## # A tibble: 21 × 22
##                                                       name
##                                                      <chr>
## 1                                  University of Göttingen
## 2                            Universitätsmedizin Göttingen
## 3           Max Planck Institute for Biophysical Chemistry
## 4                                    German Primate Center
## 5                European Neuroscience Institute Göttingen
## 6  Max Planck Institute for Dynamics and Self Organization
## 7           Max Planck Institute for Experimental Medicine
## 8              Nordwestdeutsche Forstliche Versuchsanstalt
## 9               Northwest German Forest Research Institute
## 10                                      LaVision (Germany)
## # ... with 11 more rows, and 21 more variables: wikipedia_url <chr>,
## #   links <chr>, acronyms <chr>, types <chr>, lat <chr>, lng <chr>,
## #   city <chr>, country <chr>, country_code <chr>, geonames_id <chr>,
## #   id <chr>, status <chr>, established <int>, relationship <chr>,
## #   relationship_id <chr>, ISNI <chr>, FundRef <chr>, OrgRef <chr>,
## #   Wikidata <chr>, `_version_` <dbl>, aliases <chr>
```

