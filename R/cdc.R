#' Function for LMS formula with modified (m) z-scores
#'
#' @keywords internal
#' @noRd
z_score <- function(var, l, m, s) {
  ls <- l * s
  invl <- 1 / l
  z <- (((var / m) ^ l) - 1) / (ls) # z-score formula
  sdp2 <- (m * (1 + 2 * ls) ^ (invl)) - m
  # modified z-score (+2)
  sdm2 <- m - (m * (1 - 2 * ls) ^ (invl))
  mz <-
    fifelse(var < m, (var - m) / (0.5 * sdm2), (var - m) / (sdp2 * 0.5))
  return(list(z, mz))
}

#' Function to reorder columns of data table
#'
#' @keywords internal
#' @noRd
set_cols_first <- function(DT, cols, intersection = TRUE)
{
  # thanks to hutils
  if (intersection) {
    return(setcolorder(DT, c(
      intersect(cols, names(DT)),
      setdiff(names(DT), cols)
    )))
  }
  else {
    return(setcolorder(DT, c(cols, setdiff(
      names(DT), cols
    ))))
  }
}

#' Calculate extended BMI measures
#'
#' \code{ext_bmiz} Calculates the sigma (scale parameter for the half-normal
#' distribution), extended BMI percentile, extended BMIz, and the CDC LMS
#' Z-scores for weight, height, and BMI for children between 2 and 19.9 years
#' of age. Note that for BMIs <= 95th percentile of the CDC growth charts, the
#' extended values for BMI are equal to the LMS values. The extended values
#' differ only for children who have a BMI > 95th percentile.
#'
#' This function should produce output equivalent to the SAS macro provided at
#' https://www.cdc.gov/nccdphp/dnpao/growthcharts/resources/sas.htm. The macro
#' was updated in December, 2022, according to the findings of the NCHS
#' report available at https://dx.doi.org/10.15620/cdc:121711. This function has
#' been updated to match it as of growthcleanr v2.1.0.
#'
#' The extended BMIz is the inverse cumulative distribution function (CDF) of
#' the extended BMI percentile. If the extended percentile is very close to
#' 100, the \code{qnorm} function in R produces an infinite value. This occurs
#' only if the the extended BMI percentile is > 99.99999999999999. This occurs
#' infrequently, such as a 48-month-old with a BMI > 39, and it is likely that
#' these BMIs represent data entry errors. For these cases, extended BMIz is
#' set to 8.21, a value that is slightly greater than the largest value that
#' can be calculated.
#'
#' See the \code{README.md} file for descriptions of the output columns
#' generated by this function.
#'
#' \code{data} must have columns for at least age, sex, weight, height, and bmi.
#'
#' \code{age} should be coded in months, using the most precise values available.
#' To convert to months from age in years, multiply by 12. To convert to months
#' from age in days, divide by 30.4375 (365.25 / 12).
#'
#' \code{sex} is coded as 1, boys, Boys, b, B, males, Males, m, or M for male
#' subjects or 2, girls, Girls, g, G, females, Females, f, or F for female
#' subjects. Note that this is different from \code{cleangrowth}, which uses
#' 0 (Male) and 1 (Female).
#'
#' \code{wt} should be in kilograms.
#'
#' \code{ht} should be in centimeters.
#'
#' Specify the input data parameter names for \code{age}, \code{wt},
#' \code{ht}, \code{bmi} using quotation marks. See example below.
#'
#' If the parameter \code{adjust.integer.age} is \code{TRUE} (the default),
#' 0.5 will be added to all \code{age} if all input values are integers. Set to
#' \code{FALSE} to disable.
#'
#' By default, the reference data file \code{CDCref_d.csv}, made available at
#' https://www.cdc.gov/nccdphp/dnpao/growthcharts/resources/sas.htm, is included
#' in this package for convenience. If you are developing this package, use
#' \code{ref.data.path} to adjust the path to this file from your working
#' directory if necessary.
#'
#' @param data Input data frame or data table
#'
#' @param age Name of input column containing subject age in months in quotes, default "agem"
#' @param wt Name of input column containing weight (kg) value in quotes, default "wt"
#' @param ht Name of input column containing height (cm) value in quotes, default "ht"
#' @param bmi Name of input column containing calculated BMI in quotes, default "bmi"
#' @param adjust.integer.age If age inputs are all integer, add 0.5 if TRUE;
#'   default TRUE
#' @param ref.data.path Path to directory containing reference data
#'
#' @return Expanded data frame containing computed BMI values
#'
#' @export
#' @import data.table
#' @rawNamespace import(dplyr, except = c(last, first, summarize, src, between))
#' @import labelled
#' @import magrittr
#' @importFrom stats approx pnorm qnorm
#' @rawNamespace import(R.utils, except = c(extract))
#' @examples
#' \donttest{
#' # Run on a small subset of given data
#' df <- as.data.frame(syngrowth)
#' df <- df[df$subjid %in% unique(df[, "subjid"])[1:5], ]
#' df <- cbind(df,
#'             "gcr_result" = cleangrowth(df$subjid,
#'                                        df$param,
#'                                        df$agedays,
#'                                        df$sex,
#'                                        df$measurement))
#' df_wide <- longwide(df) # convert to wide format for ext_bmiz
#' df_wide_bmi <- simple_bmi(df_wide) # compute simple BMI
#'
#' # Calling the function with default column names
#' df_bmiz <- ext_bmiz(df_wide_bmi)
#'
#' # Specifying different column names; note that quotes are used
#' dfc <- simple_bmi(df_wide)
#' colnames(dfc)[colnames(dfc) %in% c("agem", "wt", "ht")] <-
#'   c("agemos", "weightkg", "heightcm")
#' df_bmiz <- ext_bmiz(dfc, age="agemos", wt="weightkg", ht="heightcm")
#'
#' # Disabling conversion of all-integer age in months to (age + 0.5)
#' dfc <- simple_bmi(df_wide)
#' df_bmiz <- ext_bmiz(dfc, adjust.integer.age=FALSE)
#' }
ext_bmiz <- function (data,
                      age = "agem",
                      wt = "wt",
                      ht = "ht",
                      bmi = "bmi",
                      adjust.integer.age = TRUE,
                      ref.data.path = "")
{
  # avoid "no visible binding" warnings
  agemos <- agemos1 <- agemos2 <- agey <- NULL
  bmip95 <- bp <- bz <- denom <- ebp <- ebz <- haz <- l <- NULL
  lbmi1 <- lbmi2 <- lht1 <- lht2 <- lwt1 <- lwt2 <- m <- NULL
  mbmi <- mbmi1 <- mbmi2 <- mht1 <- mht2 <- mref <- mwt1 <- NULL
  mwt2 <- p95 <- s <- sbmi <- sbmi1 <- sbmi2 <- seq_ <- NULL
  sex <- sexn <- sht1 <- sht2 <- sigma <- sref <- swt1 <- NULL
  swt2 <- waz <- z1 <- `_AGEMOS1` <- NULL

  setDT(data)

  setnames(data,
           old = c(age, wt, ht, bmi),
           new = c("age", "wt", "ht", "bmi"))

  # needed for merging back with original data
  data$seq_ <- 1L:nrow(data)
  dorig <- copy(data)
  if (adjust.integer.age) {
    if (isTRUE(all.equal(data$age, round(data$age)))) {
      data[, `:=`(age, age + 0.5)]
    }
  }

  data[, sexn := toupper(substr(sex, 1, 1))]
  data[, sexn := fcase(sexn %in% c(1, 'B', 'M'), 1L,
                       sexn %in% c(2, 'G', 'F'), 2L)]

  data <- data[between(age, 24, 240) & !(is.na(wt) & is.na(ht)),
               .(seq_, sexn, age, wt, ht, bmi)]
  v1 <- c("seq_", "id", "sexn", "age", "wt", "ht", "bmi")

  dref_path <-
    ifelse(
      ref.data.path == "",
      system.file("extdata/CDCref_d.csv.gz", package = "growthcleanr"),
      paste(ref.data.path, "CDCref_d.csv.gz", sep = "")
    )
  # Note: referring to underscore-leading column as `_AGEMOS1`, i.e. with
  # backticks, results in a no visible binding warning, but vars can't start
  # with an "_", so we have to use backticks at assignment up above as well.
  dref <- fread(dref_path)[`_AGEMOS1` > 23 & denom == "age"]
  names(dref) <- tolower(names(dref))
  names(dref) <- gsub("^_", "", names(dref))
  setnames(dref, 'sex', 'sexn')

  d20 <- dref[agemos2 == 240, .(sexn,
                                agemos2,
                                lwt2,
                                mwt2,
                                swt2,
                                lbmi2,
                                mbmi2,
                                sbmi2,
                                lht2,
                                mht2,
                                sht2)]
  names(d20) <- gsub("2", "", names(d20))

  dref <- dref[, .(sexn,
                   agemos1,
                   lwt1,
                   mwt1,
                   swt1,
                   lbmi1,
                   mbmi1,
                   sbmi1,
                   lht1,
                   mht1,
                   sht1)]
  names(dref) <- gsub("1", "", names(dref))

  dref <- rbindlist(list(dref, d20))
  adj_bmi_met <- dref[agemos == 240, .(sexn, mbmi, sbmi)] %>%
    setnames(., c("sexn", "mref", "sref"))
  dref <- dref[adj_bmi_met, on = "sexn"]
  v <- c("sexn",
         "age",
         "wl",
         "wm",
         "ws",
         "bl",
         "bm",
         "bs",
         "hl",
         "hm",
         "hs",
         "mref",
         "sref")
  setnames(dref, v)
  if (length(setdiff(data$age, dref$age)) > 0) {
    uages <- unique(data$age)
    fapprox <- function(i) {
      .d <- dref[sexn == i]
      fapp <- function(vars, ...)
        approx(.d$age, vars,
               xout = uages)$y
      # Note: specifying v with "..v" gives no visible binding warning, use
      # with option
      data.frame(sapply(.d[, v, with = FALSE], fapp))
    }
    dref <- rbindlist(lapply(1:2, fapprox))
  }

  setkey(data, sexn, age)
  setkey(dref, sexn, age)
  dt <- dref[data]

  dt[, `:=`(c("waz", "mwaz"), z_score(dt$wt, dt$wl, dt$wm, dt$ws))]
  dt[, `:=`(c("haz", "mhaz"), z_score(dt$ht, dt$hl, dt$hm, dt$hs))]
  dt[, `:=`(c("bz", "mbz"), z_score(dt$bmi, dt$bl, dt$bm, dt$bs))]

  setDT(dt)
  setnames(dt, c("bl", "bm", "bs"), c("l", "m", "s"))
  dt[, `:=`(c("wl", "wm", "ws", "hl", "hm", "hs"), NULL)]

  dt <- mutate(
    dt,
    bp = 100 * pnorm(bz),
    p95 = m * (1 + l * s * qnorm(0.95)) ^ (1 / l),
    p97 = m * (1 + l * s * qnorm(0.97)) ^ (1 / l),
    bmip95 = 100 * (bmi / p95),
    wp = 100 * pnorm(waz),
    hp = 100 * pnorm(haz),

    # other BMI metrics -- PMID 31439056
    z1 = ((bmi / m) - 1) / s,
    # LMS formula when L=1: ((BMI/M)-1)/S
    dist1 = z1 * m * s,
    # unadjusted distance from median
    adist1 = z1 * sref * mref,
    # Adjusted (to age 20y) dist from median
    perc1 = z1 * 100 * s,
    # unadjusted %distance from median
    aperc1 = z1 * 100 * sref,
    # adj %distance from median

    obese = 1L * (bmi >= p95),
    sev_obese = 1L * (bmip95 >= 120)
  ) %>% setDT()

  # now create Extended z-score for BMI >=95th P
  dt[, `:=`(ebz = bz,
            ebp = bp,
            agey = age / 12)]
  dt[, `:=`(
    sigma,
    fifelse(
      sexn == 1,
      0.3728 + 0.5196 * agey - 0.0091 * agey ^ 2,
      0.8334 + 0.3712 * agey - 0.0011 * agey ^ 2
    )
  )]
  dt[bp >= 95, `:=`(ebp, 90 + 10 * pnorm((bmi - p95) / sigma))]
  dt[bp >= 95, `:=`(ebz, qnorm(ebp / 100))]
  dt[bp > 99 & is.infinite(ebz), `:=`(ebz, 8.21)]

  x <- c("agey", "mref", "sref", "sexn", "wt", "ht", "bmi")
  dt[, `:=`((x), NULL)]
  setnames(
    dt,
    c(
      "adist1",
      "aperc1",
      "bp",
      "bz",
      "mbz",
      "mwaz",
      "mhaz",
      "ebp",
      "ebz",
      "l",
      "m",
      "s"
    ),
    c(
      "adj_dist1",
      "adj_perc1",
      "original_bmip",
      "original_bmiz",
      "mod_bmiz",
      "mod_waz",
      "mod_haz",
      # DF changes
      "bmip",
      "bmiz",
      "bmi_l",
      "bmi_m",
      "bmi_s"
    )
  )

  v <- c(
    "seq_",
    "bmiz",
    "bmip",
    "waz",
    "wp",
    "haz",
    "hp",
    "p95",
    "p97",
    "bmip95",
    "mod_bmiz",
    "mod_waz",
    "mod_haz",
    "sigma",
    "original_bmip",
    "original_bmiz",
    "sev_obese",
    "obese"
  )
  dt <- dt[, v, with = FALSE]

  setkey(dt, seq_)
  setkey(dorig, seq_)
  dtot <- dt[dorig]
  set_cols_first(dtot, names(dorig))
  dtot[, `:=`(c("seq_"), NULL)]

  # Add labels for convenience
  dtot <-
    dtot %>% labelled::set_variable_labels(
      age = "Age (months)",
      ht = "Height (cm)",
      wt = "Weight (kg)",
      bmi = "BMI",
      original_bmiz = "LMS BMI-for-sex/age z-score",
      original_bmip = "LMS BMI-for-sex/age percentile",
      waz = "LMS Weight-for-sex/age z-score",
      wp = "LMS Weight-for-sex/age percentile",
      haz = "LMS Height-for-sex/age z-score",
      hp = "LMS Height-for-sex/age percentile",
      p95 = "95th percentile of BMI in growth charts",
      p97 = "97th percentile of BMI in growth charts",
      bmip95 = "BMI as a percentage of the 95th percentile",
      mod_bmiz = "Modified BMI-for-age z-score",
      mod_waz = "Modified Weight-for-age z-score",
      mod_haz = "Modified Height-for-age z-score",
      sigma = "Scale parameter for half-normal distribution",
      bmip = "LMS / Extended BMI percentile",
      bmiz = "LMS / Extended BMI z-score",
      sev_obese = "BMI >= 120% of 95th percentile (0/1)",
      obese = "BMI >= 95th percentile (0/1)"
    )
  return(dtot[])
}
