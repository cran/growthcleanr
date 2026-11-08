## ----eval = FALSE-------------------------------------------------------------
# 
# # cleangrowth() uses columns named subjid, sex, agedays, param, and measurement, unless you specify other names.
# 
# # Recommended code for version 3 using standard growthcleanr column names
# # Returns your data with results added
# cleaned <- cleangrowth(data)
# 
# # Code for version 3 that returns only the exclude column, as a vector
# exclude_codes <- cleangrowth(data)$exclude
# 
# # Closest to code for 2.2.3: name each argument and take $exclude. The code below stores it in a column named gcr_result.
# data[, gcr_result := cleangrowth(subjid = subjid, sex = sex,
#                                  agedays = agedays, param = param,
#                                  measurement = measurement)$exclude]
# 
# # Old code (will no longer work)
# data[, gcr_result := cleangrowth(subjid, param, agedays, sex, measurement)]
# 

## ----eval = FALSE-------------------------------------------------------------
# install.packages("growthcleanr")

## ----eval = FALSE-------------------------------------------------------------
# gc_runtrial(my_data)

## ----eval = FALSE-------------------------------------------------------------
# result <- cleangrowth(my_data)   # growthcleanr now takes an optional id column (unique per row); without one, ids are generated and a warning is shown

## ----eval = FALSE-------------------------------------------------------------
# result <- cleangrowth(my_data,
#                       checkpoint_dir = "gc_checkpoints",
#                       parallel = TRUE)

## ----eval = FALSE-------------------------------------------------------------
# refs <- gc_preload_refs()
# for (rep in 1:n_reps) {
#   result <- cleangrowth(data = my_data, ref_tables = refs)
#   # ...
# }

## ----eval = FALSE-------------------------------------------------------------
# result <- cleangrowth(data = my_data, parallel = TRUE, cores = 4)

## ----eval = FALSE-------------------------------------------------------------
# # From CRAN:
# remotes::install_version("growthcleanr", version = "2.2.3")
# 
# # Or from GitHub at a tagged release:
# remotes::install_github("growth-data-tools/growthcleanr@v2.2.3")

## ----eval = FALSE-------------------------------------------------------------
# # Check your installed version:
# packageVersion("growthcleanr")

