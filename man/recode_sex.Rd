% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{recode_sex}
\alias{recode_sex}
\title{Recode binary sex variable for compatibility}
\usage{
recode_sex(
  input_data,
  sourcecol = "sex",
  sourcem = "0",
  sourcef = "1",
  targetcol = "sex_recoded",
  targetm = 1L,
  targetf = 2L
)
}
\arguments{
\item{input_data}{a data frame or data table to be transformed. Expects a source column containing a binary sex variable.}

\item{sourcecol}{name of sex descriptor column. Defaults to "sex"}

\item{sourcem}{variable indicating "male" sex in input data. Defaults to "0"}

\item{sourcef}{variable indicating "female" sex in input data. Defaults to "1"}

\item{targetcol}{desired name of recoded sex descriptor column. Defaults to "sex_recoded"}

\item{targetm}{desired name of recoded sex variable indicating "male" sex in output data. Defaults to 1}

\item{targetf}{desired name of recoded sex variable indicating "female" sex in output data. Defaults to 2}
}
\value{
Returns a data table with recoded sex variables.
}
\description{
\code{recode_sex} recodes a binary sex variable for a given source column in a data frame or data table.
Useful in transforming output from growthcleanr::cleangrowth() into a format suitable for growthcleanr::ext_bmiz().
}
\examples{
# Run on given data
df <- as.data.frame(syngrowth)

# Run with all defaults
df_r <- recode_sex(df)

# Specify different targets
df_rt <- recode_sex(df, targetcol = "sexr", targetm = "Male", targetf = "Female")

# Specify different inputs
df_ri <- recode_sex(df_rt, sourcecol = "sexr", sourcem = "Male", sourcef = "Female")
}
