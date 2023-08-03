#' Generate a black tile
#'
#' This function generates a black tile devoid of any signal in each channel. The source tile should be placed in the `1_generateBlackTile > input` directory, and the produced black tile will be created in the `1_generateBlackTile > output` directory.
#'
#' @param imageJPath The absolute path where the ImageJ executable is located.
#'
#' @param wd The workspace directory root path.
#'
#' @export

runMacro_generateBlackTile = function(imageJPath, wd)
{
  file.copy(system.file("1_generateBlackTile.txt", package = "PUPAID"), file.path("macros", "1_generateBlackTile_run.txt"), overwrite = TRUE)

  macroConn = file(file.path("macros", "1_generateBlackTile_run.txt"))
  originalMacro = readLines(macroConn)
  close(macroConn)

  fileConn<-file(file.path("macros", "1_generateBlackTile_run.txt"))
  writeLines(c(paste("var FolderToUse = \"", wd, "\";\n", sep = ""), originalMacro), fileConn)
  close(fileConn)

  system(paste(imageJPath, " -batch ", file.path(wd, "macros", "1_generateBlackTile_run.txt"), sep = ""))
}
