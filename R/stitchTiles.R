#' Stitch tiles
#'
#' This function stitches in ImageJ all the tiles found in the `2_renameAndOrderTiles > output` directory (each ROI separately). The stitched ROI will be generated in the `3_stitchedTiles` directory, as well as a single text file per ROI containing the tile configuration used during stitching. The function also outputs a rds file containing the determined ROI and their characteristics (height, width, number of total tiles, number of missing tiles, etc.).
#'
#' @param renameAndOrderOutput Tiles renaming and ordering output produced by `renameAndOrderTiles()` function.
#'
#' @param imageJPath The absolute path where the ImageJ executable is located.
#'
#' @param wd The workspace directory root path.
#'
#' @importFrom foreach %do%
#'
#' @export

stitchTiles = function(renameAndOrderOutput = renameAndOrderOutput, imageJPath = imageJPath, wd = wd)
{
  r = NULL

  totalMissingTilesInfos = renameAndOrderOutput$totalMissingTilesInfos
  sampleName = renameAndOrderOutput$sampleName

  foreach::foreach(r = 1:length(totalMissingTilesInfos)) %do%
    {
      currentROI_nb = gsub("(ROI-[0-9]+);([0-9]+)x([0-9]+)", "\\1", names(totalMissingTilesInfos)[r])
      currentROI_xSize = gsub("(ROI-[0-9]+);([0-9]+)x([0-9]+)", "\\2", names(totalMissingTilesInfos)[r])
      currentROI_ySize = gsub("(ROI-[0-9]+);([0-9]+)x([0-9]+)", "\\3", names(totalMissingTilesInfos)[r])

      if(as.numeric(currentROI_xSize) > 1 | as.numeric(currentROI_ySize) > 1)
      {

        runMacro_stitchTiles(sampleName = sampleName, currentROI_nb = currentROI_nb, currentROI_xSize = currentROI_xSize, currentROI_ySize = currentROI_ySize, imageJPath = imageJPath, wd = wd)


        file.copy(file.path("2_renameAndOrderTiles", "output", currentROI_nb, paste(sampleName, currentROI_nb, ".tif", sep = "")), file.path("3_stitchedTiles", paste(sampleName, currentROI_nb, ".tif", sep = "")))

        file.copy(file.path("2_renameAndOrderTiles", "output", currentROI_nb, paste("TileConfiguration_", sampleName, currentROI_nb, ".txt", sep = "")), file.path("3_stitchedTiles", paste("TileConfiguration_", sampleName, currentROI_nb, ".txt", sep = "")))

        unlink(file.path("2_renameAndOrderTiles", "output", currentROI_nb, paste(sampleName, currentROI_nb, ".tif", sep = "")))
        unlink(file.path("2_renameAndOrderTiles", "output", currentROI_nb, paste("TileConfiguration_", sampleName, currentROI_nb, ".txt", sep = "")))

      } else
      {
        file.copy(file.path("2_renameAndOrderTiles", "output", currentROI_nb, paste(sampleName, currentROI_nb, "_tile_01.tif", sep = "")), file.path("3_stitchedTiles", paste(sampleName, currentROI_nb, ".tif", sep = "")))

      }





    }

  file.copy(file.path("2_renameAndOrderTiles", "output", "renameAndOrderOutput.rds"), file.path("3_stitchedTiles", "renameAndOrderOutput.rds"))
  unlink(file.path("2_renameAndOrderTiles", "output", "renameAndOrderOutput.rds"))


}
