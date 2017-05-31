


# Task: Given a journal's ISSN, how do I find open access articles published in that journal in a given year with R?

<https://twitter.com/StephenEglen/status/844201416478638081>

**Solution**: Crosswalk [rcrossref](https://github.com/ropensci/rcrossref/),
a client for the DOI agency [Crossref](https://www.crossref.org/)
and [roadoi](https://github.com/njahn82/roadoi), an interface
to the [oaDOI.org linking service](https://oadoi.org/).

## Fetch DOIs from Crossref by ISSN

ISSNs enable unique references to journals and can be easily
obtained from journal websites or library databases. As an example, we start
by fetching all works from the JASIST journal, which has the ISSN: 2330-1635.


```r
#
library(dplyr)
my_jn_data <- rcrossref::cr_journals(
  "2330-1635",
  filter = c(from_pub_date = "2014-01-01", until_pub_date = "2014-12-31"),
  works = TRUE,
  limit = 1000
)
my_jn_data$data
#> # A tibble: 286 x 33
#>    alternative.id
#>             <chr>
#>  1               
#>  2               
#>  3               
#>  4               
#>  5               
#>  6               
#>  7               
#>  8               
#>  9               
#> 10               
#> # ... with 276 more rows, and 32 more variables: container.title <chr>,
#> #   created <chr>, deposited <chr>, DOI <chr>, funder <list>,
#> #   indexed <chr>, ISBN <chr>, ISSN <chr>, issue <chr>, issued <chr>,
#> #   license_date <chr>, license_URL <chr>, license_delay.in.days <chr>,
#> #   license_content.version <chr>, link <list>, member <chr>,
#> #   prefix <chr>, publisher <chr>, reference.count <chr>, score <chr>,
#> #   source <chr>, subject <chr>, title <chr>, type <chr>, URL <chr>,
#> #   volume <chr>, assertion <list>, author <list>,
#> #   `clinical-trial-number` <list>, page <chr>, subtitle <chr>,
#> #   archive <chr>
```

## Call oaDOI.org

In the next step, let's call oaDOI.org to explore whether there are OA copies



```r
oa_df <- roadoi::oadoi_fetch(dois = my_jn_data$data$DOI,
                             email = "najko.jahn@gmail.com")
```

## Explore your data

### by evidence type



```r
oa_df %>%
  group_by(evidence) %>%
  summarise(Articles = n()) %>%
  mutate(Proportion = Articles / sum(Articles)) %>%
  arrange(desc(Articles)) %>%
  knitr::kable()
```



|evidence                                              | Articles| Proportion|
|:-----------------------------------------------------|--------:|----------:|
|closed                                                |      240|  0.8391608|
|oa repository (via BASE title and first author match) |       34|  0.1188811|
|oa repository (via BASE doi match)                    |        7|  0.0244755|
|oa repository (via pmcid lookup)                      |        3|  0.0104895|
|hybrid (via crossref license)                         |        2|  0.0069930|

### by green or gold open access


```r
oa_df %>%
  group_by(oa_color) %>%
  summarise(Articles = n()) %>%
  mutate(Proportion = Articles / sum(Articles)) %>%
  arrange(desc(Articles)) %>%
  knitr::kable()
```



|oa_color | Articles| Proportion|
|:--------|--------:|----------:|
|NA       |      240|  0.8391608|
|green    |       44|  0.1538462|
|blue     |        2|  0.0069930|

