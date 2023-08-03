#' Benchmark sigma pairs
#'
#' This function performs cell contouring (using Difference of Gaussians, (DoG) method) in ImageJ with different sets of sigma pairs, in order to determine the best pair for the currently analyzed tissue. This function expects an image file within the `4_testSigmaPair > input` directory with only 1 channel that you should first generate manually using ImageJ, for instance. The selected signal should be viable for automatized cell contouring, like any nucleus-restricted stain (such as DAPI) or any cell membrane-restricted stain. The selected image should be typically representative of an area with a high density of cells, in order to better estimate if the used pair of sigma values allows to clearly delineate the cells contours. For faster computation, the image could be a cropped region of the whole ROI of interest. The produced images showing the actual cell contouring will be located in the `4_testSigmaPair > output` directory.
#'
#' @param imageJPath The absolute path where the ImageJ executable is located.
#'
#' @param wd The workspace directory root path.
#'
#' @param sigmaPairsToTest A list containing numeric vectors of size 2. For each vector, the first value represents the lowest sigma value to use, whereas the second value represents the highest sigma value to use for cell contouring.
#'
#' @importFrom foreach %do%
#'
#' @export

benchmarkSigmaPairs = function(imageJPath = imageJPath, wd = wd, sigmaPairsToTest = sigmaPairsToTest)
{

  a = NULL

  foreach::foreach(a = 1:length(sigmaPairsToTest)) %do%
    {

      currentPair = sigmaPairsToTest[[a]]
      sigmaLow = currentPair[1]
      sigmaHigh = currentPair[2]

      runMacro_testSigmaPair(imageJPath = imageJPath, wd = wd, sigmaLow = sigmaLow, sigmaHigh = sigmaHigh)


    }

}
