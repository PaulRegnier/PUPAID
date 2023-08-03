#' Test a given sigma pair
#'
#' This function performs cell contouring (using Different of Gaussians, (DoG) method) in ImageJ with a given pair of sigma values. This function expects an image file within the `4_testSigmaPair > input` directory with only 1 channel that you should first generate manually using ImageJ, for instance. The selected signal should be viable for automatized cell contouring, like any nucleus-restricted stain (such as DAPI) or any cell membrane-restricted stain. The selected image should be typically representative of an area with a high density of cells, in order to better estimate if the used pair of sigma values allows to clearly delineate the cells contours. For faster computation, the image could be a cropped region of the whole ROI of interest.
#'
#' @param wd The workspace directory root path.
#'
#' @param imageJPath The absolute path where the ImageJ executable is located.
#'
#' @param sigmaLow A numeric value which represents the lowest sigma value to use for cell contouring.
#'
#' @param sigmaHigh A numeric value which represents the highest sigma value to use for cell contouring.
#'
#' @export

runMacro_testSigmaPair = function(wd, imageJPath, sigmaLow, sigmaHigh)
{
  file.copy(system.file("4_testSigmaPair.txt", package = "PUPAID"), file.path("macros", "4_testSigmaPair_run.txt"), overwrite = TRUE)


  macroConn = file(file.path("macros", "4_testSigmaPair_run.txt"))
  originalMacro = readLines(macroConn)
  close(macroConn)

  fileConn<-file(file.path("macros", "4_testSigmaPair_run.txt"))
  writeLines(c(paste("var FolderToUse = \"", file.path(wd, "4_testSigmaPair"), "\";\n", sep = ""),
               paste("var SigmaLow = \"", sigmaLow, "\";\n", sep = ""),
               paste("var SigmaHigh = \"", sigmaHigh, "\";\n", sep = ""),
               originalMacro), fileConn)
  close(fileConn)

  system(paste(imageJPath, " -macro ", file.path(wd, "macros", "4_testSigmaPair_run.txt"), sep = ""))


}
