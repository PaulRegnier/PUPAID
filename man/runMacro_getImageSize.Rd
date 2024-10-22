% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/runMacro_getImageSize.R
\name{runMacro_getImageSize}
\alias{runMacro_getImageSize}
\title{Get the image size}
\usage{
runMacro_getImageSize(imageJPath, wd)
}
\arguments{
\item{imageJPath}{The absolute path where the ImageJ executable is located.}

\item{wd}{The workspace directory root path.}
}
\description{
This function opens in ImageJ the first tile contained in the \verb{1_generateBlackTile > input} directory and extract its width and height in µm, which will be useful for the automatic renaming and ordering of the ROI contained in the sample.
}
