#' Stitch tiles from a single ROI
#'
#' This function stitches in ImageJ all the tiles found in the `2_renameAndOrderTiles > output` directory (for a single given ROI). The stitched ROI will be generated in the `3_stitchedTiles` directory. This function should only be launched through the `stitchTiles()` function.
#'
#' @param sampleName The name of the treated sample. Should be obtained through the `stitchTiles()` function.
#'
#' @param currentROI_nb The number of the current ROI to stitch. Should be obtained through the `stitchTiles()` function.
#'
#' @param currentROI_xSize The number of tiles (X axis) for the current ROI. Should be obtained through the `stitchTiles()` function.
#'
#' @param currentROI_ySize The number of tiles (Y axis) for the current ROI. Should be obtained through the `stitchTiles()` function.
#'
#' @param imageJPath The absolute path where the ImageJ executable is located. Should be obtained through the `stitchTiles()` function.
#'
#' @param wd The workspace directory root path. Should be obtained through the `stitchTiles()` function.
#'
#' @export

runMacro_stitchTiles = function(sampleName, currentROI_nb, currentROI_xSize, currentROI_ySize, imageJPath, wd)
{
  file.copy(system.file("3_stitchTiles.txt", package = "PUPAID"), file.path("macros", "3_stitchTiles_run.txt"), overwrite = TRUE)


  macroConn = file(file.path("macros", "3_stitchTiles_run.txt"))
  originalMacro = readLines(macroConn)
  close(macroConn)

  fileConn<-file(file.path("macros", "3_stitchTiles_run.txt"))
  writeLines(c(paste("var currentFolderPath = \"", file.path(wd, "2_renameAndOrderTiles", "output", currentROI_nb), "\";\n", sep = ""),
               paste("var currentSampleName = \"", sampleName, "\";\n", sep = ""),
               paste("var currentROI = \"", currentROI_nb, "\";\n", sep = ""),
               paste("var currentROI_xSize = \"", currentROI_xSize, "\";\n", sep = ""),
               paste("var currentROI_ySize = \"", currentROI_ySize, "\";\n", sep = ""),
               originalMacro), fileConn)
  close(fileConn)

 system(paste(imageJPath, " -batch ", file.path(wd, "macros", "3_stitchTiles_run.txt"), sep = ""))

}
