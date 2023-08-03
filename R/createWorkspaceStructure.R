#' Setup the working directory
#'
#' This function setups the workspace structure. Within the specified `wd` path, every directory and subsequent content will be wiped and several empty directories and subdirectories will be created.
#'
#' @param wd The path in which the blank workspace will be created.
#'
#' @export

createWorkspaceStructure = function(wd = wd)
{
  if(dir.exists(file.path(wd, "1_generateBlackTile")))
  {

    unlink(file.path(wd, "1_generateBlackTile"), recursive = TRUE)
  }


  dir.create(file.path(wd, "1_generateBlackTile"))
  dir.create(file.path(wd, "1_generateBlackTile", "input"))
  dir.create(file.path(wd, "1_generateBlackTile", "output"))

  if(dir.exists(file.path(wd, "2_renameAndOrderTiles")))
  {

    unlink(file.path(wd, "2_renameAndOrderTiles"), recursive = TRUE)
  }


  dir.create(file.path(wd, "2_renameAndOrderTiles"))
  dir.create(file.path(wd, "2_renameAndOrderTiles", "input"))
  dir.create(file.path(wd, "2_renameAndOrderTiles", "output"))

  if(dir.exists(file.path(wd, "3_stitchedTiles")))
  {

    unlink(file.path(wd, "3_stitchedTiles"), recursive = TRUE)
  }


  dir.create(file.path(wd, "3_stitchedTiles"))

  if(dir.exists(file.path(wd, "4_testSigmaPair")))
  {

    unlink(file.path(wd, "4_testSigmaPair"), recursive = TRUE)
  }


  dir.create(file.path(wd, "4_testSigmaPair"))
  dir.create(file.path(wd, "4_testSigmaPair", "input"))
  dir.create(file.path(wd, "4_testSigmaPair", "output"))


  if(dir.exists(file.path(wd, "5_analyzeROI")))
  {

    unlink(file.path(wd, "5_analyzeROI"), recursive = TRUE)
  }

  dir.create(file.path(wd, "5_analyzeROI"))
  dir.create(file.path(wd, "5_analyzeROI", "input"))
  dir.create(file.path(wd, "5_analyzeROI", "output"))

  if(dir.exists(file.path(wd, "macros")))
  {

    unlink(file.path(wd, "macros"), recursive = TRUE)
  }

  dir.create(file.path(wd, "macros"))


  gc()

}
