% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{simple_bmi}
\alias{simple_bmi}
\title{Compute BMI using standard formula}
\usage{
simple_bmi(wide_df, wtcol = "wt", htcol = "ht")
}
\arguments{
\item{wide_df}{A data frame or data table containing heights and weights in
wide format, e.g., after transformation with longwide()}

\item{wtcol}{name of observation height value column, default 'wt'}

\item{htcol}{name of subject weight value column, default 'ht'}
}
\value{
Returns a data table with the added column "bmi"
}
\description{
\code{simple_bmi} Computes BMI using standard formula. Assumes input compatible with
output from longwide().
}
\examples{
\donttest{
# Simple usage
# Run on a small subset of given data
df <- as.data.frame(syngrowth)
df <- df[df$subjid \%in\% unique(df[, "subjid"])[1:2], ]
df <- cbind(df,
            "gcr_result" = cleangrowth(df$subjid,
                                       df$param,
                                       df$agedays,
                                       df$sex,
                                       df$measurement))
# Convert to wide format
wide_df <- longwide(df)
wide_df_with_bmi <- simple_bmi(wide_df)

# Specifying different column names; note that quotes are used
colnames(wide_df)[colnames(wide_df) \%in\% c("wt", "ht")] <-
  c("weight", "height")
wide_df_with_bmi <- simple_bmi(wide_df, wtcol = "weight", htcol = "height")
}
}
