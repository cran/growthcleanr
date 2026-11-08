## ----eval = FALSE-------------------------------------------------------------
# library(data.table)  # provides fread() for fast loading of data
# my_data <- fread("my_data.csv")

## ----eval = FALSE-------------------------------------------------------------
# library(data.table)  # provides fwrite()
# cleaned_data <- cleangrowth(my_data)
# fwrite(cleaned_data, "my_results.csv")

## ----eval = FALSE-------------------------------------------------------------
# library(haven)
# library(growthcleanr)
# 
# my_data <- read_dta("my_data.dta")            # read a Stata file
# cleaned_data <- cleangrowth(my_data)          # run growthcleanr
# write_dta(cleaned_data, "my_results.dta")     # write the results as a Stata file

