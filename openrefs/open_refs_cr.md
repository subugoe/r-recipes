


## How many publishers have opened-up their references?

Question was asked by @rmounce (@rossmounce on GH)
<https://github.com/ropensci/rcrossref/issues/158>

Let's implement Scott Chamberlain's solution


```r
library(tidyverse)
library(knitr)
library(rcrossref)
```

### Publisher that have not opened-up their references, yet


```r
no_refs <- lapply(c(0, seq(1001,10000, by = 1000)), function(x) {
  offset <- x
  tt <- rcrossref::cr_members(filter = list(has_public_references = FALSE), limit = 1000, offset = offset)
  tt$data
})
no_refs_df <- bind_rows(no_refs) %>%
  select(1:6) %>%
  mutate(total.dois = as.numeric(total.dois)) %>%
  filter(current.dois > 0) %>%
  arrange(desc(total.dois))
```

tibble


```r
no_refs_df
#> # A tibble: 7,046 x 6
#>       id primary_name  location   last_status_che… total.dois current.dois
#>    <int> <chr>         <chr>      <date>                <dbl> <chr>       
#>  1    78 Elsevier BV   230 Park … 2018-04-04         16105368 1486170     
#>  2   263 Institute of… 445 Hoes … 2018-04-04          3196252 448946      
#>  3   276 Ovid Technol… 100 River… 2018-04-04          1820215 120939      
#>  4  1121 JSTOR         301 E. Li… 2018-04-04          1759017 2867        
#>  5   266 IOP Publishi… Temple Ci… 2018-04-04           776954 83684       
#>  6   194 Georg Thieme… Ruedigers… 2018-04-04           758611 62959       
#>  7    10 American Med… 330 N. Wa… 2018-04-04           593700 12635       
#>  8   189 SPIE-Intl So… P.O. Box … 2018-04-04           492215 41460       
#>  9   200 University o… Attn:Elma… 2018-04-04           436402 10976       
#> 10    15 American Psy… 750 First… 2018-04-04           299286 10853       
#> # ... with 7,036 more rows
```

Top 10 nicely printed


```r
no_refs_df %>%
  head(10) %>%
  knitr::kable()
```



|   id|primary_name                                             |location                                                                                                                     |last_status_check_time | total.dois|current.dois |
|----:|:--------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------|:----------------------|----------:|:------------|
|   78|Elsevier BV                                              |230 Park Avenue Suite 800 Shantae McGee New York NY 10169-0935 United States                                                 |2018-04-04             |   16105368|1486170      |
|  263|Institute of Electrical and Electronics Engineers (IEEE) |445 Hoes Lane Piscataway NJ 08855-1331 United States                                                                         |2018-04-04             |    3196252|448946       |
|  276|Ovid Technologies (Wolters Kluwer Health)                |100 River Ridge Drive Suite 207 333 Seventh Avenue Norwood MA 2062                                                           |2018-04-04             |    1820215|120939       |
| 1121|JSTOR                                                    |301 E. Liberty Suite 400 Suite 400 Ann Arbor MI 48104                                                                        |2018-04-04             |    1759017|2867         |
|  266|IOP Publishing                                           |Temple Circus Temple Way Temple Way Bristol BS1 6BE United Kingdom                                                           |2018-04-04             |     776954|83684        |
|  194|Georg Thieme Verlag KG                                   |Ruedigerstrasse 14 Stuttgart 70469 Germany                                                                                   |2018-04-04             |     758611|62959        |
|   10|American Medical Association (AMA)                       |330 N. Wabash Avenue Contact person: Elaine Williams Contract number: 23907 PO number: 228016 Chicago IL 60611 United States |2018-04-04             |     593700|12635        |
|  189|SPIE-Intl Soc Optical Eng                                |P.O. Box 10 Bellingham WA 98227-0010 United States                                                                           |2018-04-04             |     492215|41460        |
|  200|University of Chicago Press                              |Attn:Elmars Bilsens 1427 E 60th Street Chicago IL 60637-2954 United States                                                   |2018-04-04             |     436402|10976        |
|   15|American Psychological Association (APA)                 |750 First Street NE Washington 20002-4242 United States                                                                      |2018-04-04             |     299286|10853        |

Export data as csv


```r
rio::export(no_refs_df, "no_public_refs.csv")
```

### Publishers with open refeference


```r
public_refs <- lapply(c(0, seq(1001,10000, by = 1000)), function(x) {
  offset <- x
  tt <- rcrossref::cr_members(filter = list(has_public_references = TRUE), limit = 1000, offset = offset)
  tt$data
})
public_refs_df <- bind_rows(public_refs) %>%
  select(1:6) %>%
  mutate(total.dois = as.numeric(total.dois)) %>%
  arrange(desc(total.dois))
```

tibble


```r
public_refs_df
#> # A tibble: 1,062 x 6
#>       id primary_name  location   last_status_che… total.dois current.dois
#>    <int> <chr>         <chr>      <date>                <dbl> <chr>       
#>  1   297 Springer Nat… 233 Sprin… 2018-04-04         10180248 890478      
#>  2   311 Wiley-Blackw… 111 River… 2018-04-04          8442794 535113      
#>  3   301 Informa UK L… Informa U… 2018-04-04          4371556 341825      
#>  4   286 Oxford Unive… Academic … 2018-04-04          3168344 251355      
#>  5   179 SAGE Publica… 2455 Tell… 2018-04-04          2102183 139926      
#>  6   316 American Che… CAS, a di… 2018-04-04          1503782 106455      
#>  7    56 Cambridge Un… The Edinb… 2018-04-04          1442370 62137       
#>  8   339 Springer Nat… 233 Sprin… 2018-04-04          1395059 126291      
#>  9   374 Walter de Gr… Genthiner… 2018-04-04           902814 73596       
#> 10   239 BMJ           BMA House… 2018-04-04           849961 54889       
#> # ... with 1,052 more rows
```

Top 10 nicely printed


```r
public_refs_df %>%
  head(10) %>%
  knitr::kable()
```



|  id|primary_name                     |location                                                                                                                |last_status_check_time | total.dois|current.dois |
|---:|:--------------------------------|:-----------------------------------------------------------------------------------------------------------------------|:----------------------|----------:|:------------|
| 297|Springer Nature                  |233 Spring St. Attn: Joerg Schreiber New York NY 10013 United States                                                    |2018-04-04             |   10180248|890478       |
| 311|Wiley-Blackwell                  |111 River Street Hoboken NJ 07030 United States                                                                         |2018-04-04             |    8442794|535113       |
| 301|Informa UK Limited               |Informa UK Limited,Purchase Ledger Department PO Box 7044,Sheepen Place P.O. Box 7044 Colchester CO3 3WQ United Kingdom |2018-04-04             |    4371556|341825       |
| 286|Oxford University Press (OUP)    |Academic Division Journals Great Clarendon Street Great Clarendon Street Oxford OX2 6DP United Kingdom                  |2018-04-04             |    3168344|251355       |
| 179|SAGE Publications                |2455 Teller Road Thousand Oaks CA 91320 United States                                                                   |2018-04-04             |    2102183|139926       |
| 316|American Chemical Society (ACS)  |CAS, a division of the American Chemical Society 2540 Olentangy River Road Columbus Ohio 43210 United States            |2018-04-04             |    1503782|106455       |
|  56|Cambridge University Press (CUP) |The Edinburgh Bldg Shaftesbury Rd Shaftesbury Rd Cambridge CB2 2RU United Kingdom                                       |2018-04-04             |    1442370|62137        |
| 339|Springer Nature                  |233 Spring St. Attn: Joerg Schreiber New York NY 10013 United States                                                    |2018-04-04             |    1395059|126291       |
| 374|Walter de Gruyter GmbH           |Genthiner Strabe13 Berlin D-10785 Germany                                                                               |2018-04-04             |     902814|73596        |
| 239|BMJ                              |BMA House Tavistock Square Tavistock Square London WC1H 9JP United Kingdom                                              |2018-04-04             |     849961|54889        |

Export data as csv


```r
readr::write_csv(public_refs_df, "public_refs.csv")
```

