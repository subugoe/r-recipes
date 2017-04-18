

```r
library(dplyr)
library(readr)
apc_df <-
  readr::read_csv("https://raw.githubusercontent.com/OpenAPC/openapc-de/master/data/apc_de.csv")
```

```
## Warning: ungenutzte Verbindung 6 (https://raw.githubusercontent.com/
## OpenAPC/openapc-de/master/data/apc_de.csv) geschlossen
```

```
## Parsed with column specification:
## cols(
##   institution = col_character(),
##   period = col_integer(),
##   euro = col_double(),
##   doi = col_character(),
##   is_hybrid = col_logical(),
##   publisher = col_character(),
##   journal_full_title = col_character(),
##   issn = col_character(),
##   issn_print = col_character(),
##   issn_electronic = col_character(),
##   issn_l = col_character(),
##   license_ref = col_character(),
##   indexed_in_crossref = col_logical(),
##   pmid = col_integer(),
##   pmcid = col_character(),
##   ut = col_character(),
##   url = col_character(),
##   doaj = col_logical()
## )
```

two-sided, null hypothesis: Fees for publishing in fully and hybrid open access journals do not differ


```r
hybrid_euro <- apc_df %>%
  filter(is_hybrid == TRUE) %>%
  .$euro
fully_euro <- apc_df %>%
  filter(is_hybrid == FALSE) %>%
  .$euro

t.test(hybrid_euro,
       fully_euro,
       var.equal = FALSE)
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  hybrid_euro and fully_euro
## t = 116.79, df = 21778, p-value < 2.2e-16
## alternative hypothesis: true difference in means is not equal to 0
## 95 percent confidence interval:
##  1050.878 1086.753
## sample estimates:
## mean of x mean of y 
##  2467.145  1398.330
```

one-sided, Publishing in hybrid open access journals is not more expensive than publishing in full-oa journals


```r
t.test(hybrid_euro,
       fully_euro,
       var.equal = FALSE,
       alternative = "greater")
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  hybrid_euro and fully_euro
## t = 116.79, df = 21778, p-value < 2.2e-16
## alternative hypothesis: true difference in means is greater than 0
## 95 percent confidence interval:
##  1053.762      Inf
## sample estimates:
## mean of x mean of y 
##  2467.145  1398.330
```

