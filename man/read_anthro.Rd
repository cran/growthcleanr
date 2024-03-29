% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/growth.R
\name{read_anthro}
\alias{read_anthro}
\title{Function to calculate z-scores and csd-scores based on anthro tables.}
\usage{
read_anthro(path = "", cdc.only = FALSE, prelim_infants = FALSE)
}
\arguments{
\item{path}{Path to supplied reference anthro data. Defaults to package anthro tables.}

\item{cdc.only}{Whether or not only CDC data should be used. Defaults to false.}

\item{prelim_infants}{TRUE/FALSE. Run the in-development release of the infants algorithm (expands pediatric algorithm to improve performance for children 0 – 2 years). Not recommended for use in research. For more information regarding the logic of the algorithm, see the vignette 'Preliminary Infants Algorithm.' Defaults to FALSE.}
}
\value{
Function for calculating BMI based on measurement, age in days, sex, and measurement value.
}
\description{
Function to calculate z-scores and csd-scores based on anthro tables.
}
\examples{
\donttest{
# Return calculating function with all defaults
afunc <- read_anthro()

# Return calculating function while specifying a path and using only CDC data
afunc <- read_anthro(path = system.file("extdata", package = "growthcleanr"),
                     cdc.only = TRUE)
}
}
