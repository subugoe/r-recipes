#' ## Get number of journal articles per year and publisher
# 
rcrossref::cr_members(c("311", "297"), # wiley and springer 
                      filter = c(from_pub_date = "2014-01-01", until_pub_date = "2014-12-31", 
                                 type="journal-article"),
                      works = TRUE)$meta
