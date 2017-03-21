


# Task: Given a journal's ISSN, how do I find DOIs published in that jnl
in a given year with R?

<https://twitter.com/StephenEglen/status/844201416478638081>

**Solution**: Crosswalk [rcrossref](https://github.com/ropensci/rcrossref/),
a client for the DOI agency [Crossref](https://www.crossref.org/)
and [roadoi](https://github.com/njahn82/roadoi), an interface
to the [oaDOI.org linking service](https://oadoi.org/).
roadoi is only available from GitHub.

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
head(my_jn_data$data)
#> # A tibble: 6 × 33
#>   alternative.id
#>            <chr>
#> 1               
#> 2               
#> 3               
#> 4               
#> 5               
#> 6               
#> # ... with 32 more variables: container.title <chr>, created <chr>,
#> #   deposited <chr>, DOI <chr>, funder <list>, indexed <chr>, ISBN <chr>,
#> #   ISSN <chr>, issue <chr>, issued <chr>, license_date <chr>,
#> #   license_URL <chr>, license_delay.in.days <chr>,
#> #   license_content.version <chr>, link <list>, member <chr>, page <chr>,
#> #   prefix <chr>, publisher <chr>, reference.count <chr>, score <chr>,
#> #   source <chr>, subject <chr>, subtitle <chr>, title <chr>, type <chr>,
#> #   URL <chr>, volume <chr>, assertion <list>, author <list>,
#> #   `clinical-trial-number` <list>, archive <chr>
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
  arrange(desc(Articles))
#> # A tibble: 4 × 3
#>                                evidence Articles  Proportion
#>                                   <chr>    <int>       <dbl>
#> 1                                closed      246 0.860139860
#> 2  oa repository (via BASE title match)       35 0.122377622
#> 3      oa repository (via pmcid lookup)        3 0.010489510
#> 4 hybrid journal (via crossref license)        2 0.006993007
```

### by green or gold open access


```r
oa_df %>%
  group_by(oa_color) %>%
  summarise(Articles = n()) %>%
  mutate(Proportion = Articles / sum(Articles)) %>%
  arrange(desc(Articles))
#> # A tibble: 3 × 3
#>   oa_color Articles  Proportion
#>      <chr>    <int>       <dbl>
#> 1     <NA>      246 0.860139860
#> 2    green       38 0.132867133
#> 3     gold        2 0.006993007
```

