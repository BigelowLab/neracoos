% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nc.R
\name{nc_get_location}
\alias{nc_get_location}
\title{Retrieve location information (lon, lat, z)}
\usage{
nc_get_location(x, dims = c("lon", "lat", "depth"))
}
\arguments{
\item{x}{ncdf4 class object}

\item{dims}{character, the name of the dimensions to retrieve}
}
\value{
a named list
}
\description{
Retrieve location information (lon, lat, z)
}
