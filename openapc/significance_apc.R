library(dplyr)
library(readr)
apc_df <-
  readr::read_csv("https://raw.githubusercontent.com/OpenAPC/openapc-de/master/data/apc_de.csv")

#' two-sided, null hypothesis: Fees for publishing in fully and hybrid open access journals do not differ
hybrid_euro <- apc_df %>%
  filter(is_hybrid == TRUE) %>%
  .$euro
fully_euro <- apc_df %>%
  filter(is_hybrid == FALSE) %>%
  .$euro

t.test(hybrid_euro,
       fully_euro,
       var.equal = FALSE)

#' one-sided, Publishing in hybrid open access journals is not more expensive than publishing in full-oa journals
t.test(hybrid_euro,
       fully_euro,
       var.equal = FALSE,
       alternative = "greater")
