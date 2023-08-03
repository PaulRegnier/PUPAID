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
