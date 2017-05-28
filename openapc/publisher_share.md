## Get number of journal articles per year and publisher


```r
# 
rcrossref::cr_members(c("311", "297"), # wiley and springer 
                      filter = c(from_pub_date = "2014-01-01", until_pub_date = "2014-12-31", 
                                 type="journal-article"),
                      works = TRUE)$meta
```

```
##   member_ids total_results search_terms start_index items_per_page
## 1        311        215706           NA           0             20
## 2        297        262905           NA           0             20
```

