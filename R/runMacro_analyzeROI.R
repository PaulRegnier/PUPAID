#' Analyze ROI
#'
#' This function analyzes the ROI located in the `5_analyzeROI > input` directory. First, the user will be asked to rename each channel embedded within the ROI according to a specific format (see below), and then select which channel to use for cell contouring. Then, data within each channel will be independently transformed to remove background noise and locally enhance contrast. Afterwards, Difference of Gaussians (DoG) method will be applied with the desired `sigmaLow` and `sigmaHigh` values for cell contouring. Then, the transformed signals for each remaining channel will be measured inside each determined cell before exportation in TSV format. In parallel, processed images will also be produced and saved. All the outputs will be located in the `5_analyzeROI > output` directory. Please note that because of some technical limitations, this function will only launch a new instance of ImageJ without launching the actual analysis macro. Instead, the user should run `Plugins > Macros > Run...` within ImageJ in order to launch the edited macro of interest named `5_analyzeROI_run.txt` and located in the `macros` directory.
#'
#' @param imageJPath The absolute path where the ImageJ executable is located.
#'
#' @param wd The workspace directory root path.
#'
#' @param sigmaLow A numeric value which represents the lowest sigma value to use for cell contouring.
#'
#' @param sigmaHigh A numeric value which represents the highest sigma value to use for cell contouring.
#'
#' @export

runMacro_analyzeROI = function(imageJPath, wd, sigmaLow, sigmaHigh)
{
  file.copy(system.file("5_analyzeROI.txt", package = "PUPAID"), file.path("macros", "5_analyzeROI_run.txt"), overwrite = TRUE)

  macroConn = file(file.path("macros", "5_analyzeROI_run.txt"))
  originalMacro = readLines(macroConn)
  close(macroConn)

  fileConn<-file(file.path("macros", "5_analyzeROI_run.txt"))
  writeLines(c(paste("var FolderToUse = \"", file.path(wd, "5_analyzeROI"), "\";\n", sep = ""),
               paste("var SigmaLow = \"", sigmaLow, "\";\n", sep = ""),
               paste("var SigmaHigh = \"", sigmaHigh, "\";\n", sep = ""),
               originalMacro), fileConn)
  close(fileConn)

  # system(paste(imageJPath, " ", file.path(wd, "macros", "5_analyzeROI_run.txt"), sep = ""), wait = FALSE, invisible = FALSE)
  system(paste(imageJPath), wait = FALSE)
}
