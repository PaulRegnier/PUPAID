#' Get the image size
#'
#' This function opens in ImageJ the first tile contained in the `1_generateBlackTile > input` directory and extract its width and height in µm, which will be useful for the automatic renaming and ordering of the ROI contained in the sample.
#'
#' @param imageJPath The absolute path where the ImageJ executable is located.
#'
#' @param wd The workspace directory root path.
#'
#' @export

runMacro_getImageSize = function(imageJPath, wd)
{
  file.copy(system.file("2_getImageSize.txt", package = "PUPAID"), file.path("macros", "2_getImageSize_run.txt"), overwrite = TRUE)

  macroConn = file(file.path("macros", "2_getImageSize_run.txt"))
  originalMacro = readLines(macroConn)
  close(macroConn)

  fileConn<-file(file.path("macros", "2_getImageSize_run.txt"))
  writeLines(c(paste("var FolderToUse = \"", wd, "\";\n", sep = ""), originalMacro), fileConn)
  close(fileConn)

  macroOutput = system(paste(imageJPath, " -batch ", file.path(wd, "macros", "2_getImageSize_run.txt"), sep = ""), intern = TRUE)

  macroOutput = macroOutput[(length(macroOutput)-1):(length(macroOutput))]
  macroOutput = as.numeric(macroOutput)
  macroOutput = round(macroOutput, 2)

  return(macroOutput)
}
