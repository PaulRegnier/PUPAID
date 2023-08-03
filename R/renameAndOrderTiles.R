#' Rename and order tiles for stitching
#'
#' This function renames and orders every tile found in the `2_renameAndOrderTiles > input` directory. The function will automatically determine the embedded ROI using the tiles coordinates and separate them accordingly in dedicated directories. It will also rename the tiles in a way suitable for ImageJ stitching.
#'
#' @param AOI_x The width of a single tile (in real length unit, not in pixels).
#'
#' @param AOI_y The height of a single tile (in real length unit, not in pixels).
#'
#' @return A list containing information about identified ROI (sample name, dimensions, tiles, etc.).
#'
#' @importFrom foreach %do%
#'
#' @export

renameAndOrderTiles = function(AOI_x, AOI_y)
{

  a = NULL
  b = NULL

  files = list.files(file.path("2_renameAndOrderTiles", "input"))

  sampleName = gsub("^(.+)\\[(.+)$", "\\1", files[1])

  filesMod = gsub("^(.+)\\[(.+)\\](.+)$", "\\2", files)

  x = as.numeric(gsub("^(.+),(.+)$", "\\1", filesMod))
  y = as.numeric(gsub("^(.+),(.+)$", "\\2", filesMod))

  coordinates = data.frame(originalFileName = files, x = x, y = y)


  coordinates = coordinates[order(coordinates$x, coordinates$y), ]
  coordinates$ROI = 0
  coordinates$tile_x = 0
  coordinates$tile_y = 0

  foreach::foreach(a = 1:nrow(coordinates)) %do%
    {

      currentX = coordinates[a, "x"]
      currentY = coordinates[a, "y"]

      if(a == 1)
      {
        coordinates[a, "ROI"] = 1
        coordinates[a, "tile_x"] = 1
        coordinates[a, "tile_y"] = 1

      }
      else
      {
        globalRatiosX = (currentX - coordinates[coordinates$ROI > 0, "x"])/AOI_x

        globalRatiosY = (currentY - coordinates[coordinates$ROI > 0, "y"])/AOI_y

        if(length(which(globalRatiosX == round(globalRatiosX))) > 0 | length(which(globalRatiosY == round(globalRatiosY))) > 0) # Is the current ROI sharing a X coordinate with another already classified tile ?
        {


          roundRatiosX_ID = which(globalRatiosX == round(globalRatiosX))
          roundRatiosY_ID = which(globalRatiosY == round(globalRatiosY))

          associatedData = coordinates[roundRatiosX_ID, ]
          associatedData$ratioX = globalRatiosX[roundRatiosX_ID]
          associatedData$ratioY = globalRatiosY[roundRatiosY_ID]

          refTileX = associatedData[1, "tile_x"]
          refTileY = associatedData[1, "tile_y"]
          refROI = associatedData[1, "ROI"]
          ratioTileX = associatedData[1, "ratioX"]
          ratioTileY = associatedData[1, "ratioY"]

          coordinates[a, "ROI"] = refROI
          coordinates[a, "tile_x"] = refTileX + ratioTileX
          coordinates[a, "tile_y"] = refTileY + ratioTileY



        } else {

          coordinates[a, "ROI"] = max(coordinates$ROI) + 1
          coordinates[a, "tile_x"] = 1
          coordinates[a, "tile_y"] = 1

        }

      }


    }

  totalROI = unique(coordinates$ROI)
  totalMissingTilesInfos = list()

  totalMissingTilesInfosNames = NULL

  coordinates$tileNb = NULL
  coordinates$newFileName = NULL

  foreach::foreach (b = 1:length(totalROI)) %do%
    {
      currentROI = totalROI[b]

      if(min(coordinates[coordinates$ROI == currentROI, ]$tile_y) <= 0)
      {

        coordinates[coordinates$ROI == currentROI, ]$tile_y = coordinates[coordinates$ROI == currentROI, ]$tile_y + abs(min(coordinates[coordinates$ROI == currentROI, ]$tile_y)) + 1

      }

      if(min(coordinates[coordinates$ROI == currentROI, ]$tile_x) <= 0)
      {

        coordinates[coordinates$ROI == currentROI, ]$tile_x = coordinates[coordinates$ROI == currentROI, ]$tile_x + abs(min(coordinates[coordinates$ROI == currentROI, ]$tile_x)) + 1

      }


      currentROIdata = coordinates[coordinates$ROI == currentROI, ]

      ROI_sizeX = max(currentROIdata$tile_x)
      ROI_sizeY = max(currentROIdata$tile_y)

      tileFinalNb = ROI_sizeY * (currentROIdata$tile_x - 1) + currentROIdata$tile_y

      IDsToEdit = which(tileFinalNb <= 9)

      if(length(IDsToEdit) > 0)
      {

        tileFinalNb[IDsToEdit] = paste("0", tileFinalNb[IDsToEdit], sep = "")
      }

      missingTilesInfos = NULL

      coordinates[coordinates$ROI == currentROI, "tileNb"] = ROI_sizeY * (currentROIdata$tile_x - 1) + currentROIdata$tile_y
      coordinates[coordinates$ROI == currentROI, "newFileName"] = paste(sampleName, "ROI-", b, "_tile_", tileFinalNb, ".tif", sep = "")

      dir.create(file.path("2_renameAndOrderTiles", "output", paste("ROI-", b, sep = "")))



      foreach::foreach(c = 1:ROI_sizeX) %do%
        {

          currentColumnData = currentROIdata[currentROIdata$tile_x == c, ]

          missingTilesInColumn = which(c(1:ROI_sizeY) %in% currentColumnData$tile_y == FALSE)

          if(length(missingTilesInColumn) > 0)
          {

            missingTileFinalNb = (ROI_sizeY * (c - 1)) + missingTilesInColumn

            IDsToEdit = which(missingTileFinalNb <= 9)

            if(length(IDsToEdit) > 0)
            {
              missingTileFinalNb[IDsToEdit] = paste("0", missingTileFinalNb[IDsToEdit], sep = "")

            }

            missingTilesInfos = c(missingTilesInfos, paste("[x=", c, ";y=", missingTilesInColumn, ";nb=", missingTileFinalNb, "]", sep = ""))

            file.copy(file.path("1_generateBlackTile", "output", "blackTile.tif"), file.path("2_renameAndOrderTiles", "output", paste("ROI-", b, sep = ""), paste(sampleName, "ROI-", b, "_tile_", missingTileFinalNb, ".tif", sep = "")))


          }
        }


      if(is.null(missingTilesInfos) == TRUE)
      {

        missingTilesInfos = ""
      }

      totalMissingTilesInfos[[b]] = missingTilesInfos


      totalMissingTilesInfosNames = c(totalMissingTilesInfosNames, paste("ROI-", b, ";", ROI_sizeX, "x", ROI_sizeY, sep = ""))


      file.copy(file.path("2_renameAndOrderTiles", "input", coordinates[coordinates$ROI == currentROI, "originalFileName"]), file.path("2_renameAndOrderTiles", "output", paste("ROI-", b, sep = "")))

      file.rename(file.path("2_renameAndOrderTiles", "output", paste("ROI-", b, sep = ""), coordinates[coordinates$ROI == currentROI, "originalFileName"]), file.path("2_renameAndOrderTiles", "output", paste("ROI-", b, sep = ""), coordinates[coordinates$ROI == currentROI, "newFileName"]))


    }

  names(totalMissingTilesInfos) = totalMissingTilesInfosNames

  renameAndOrderOutput = list(sampleName = sampleName, totalMissingTilesInfos = totalMissingTilesInfos)

  saveRDS(renameAndOrderOutput, file = file.path("2_renameAndOrderTiles", "output", "renameAndOrderOutput.rds"))

  return(renameAndOrderOutput)

}
