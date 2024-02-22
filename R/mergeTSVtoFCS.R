#' Merge TSV files to FCS
#'
#' This function merges every TSV file found in the `5_analyzeROI > output` directory into a single FCS file. This FCS file could be directly used in standard flow cytometry analysis softwares such as FlowJo, Kaluza or others.
#'
#' @importFrom foreach %do%
#'
#' @export

mergeTSVtoFCS = function()
{

  a = NULL
  b = NULL

  filesToImport = list.files(file.path("5_analyzeROI", "output"), pattern = "*.tsv")

  totalData = vector(mode = "list", length = length(filesToImport))
  foreach::foreach(a = 1:length(filesToImport)) %do%
    {
      currentFileToOpen = filesToImport[a]
      currentFileData = data.table::fread(file.path("5_analyzeROI", "output", currentFileToOpen), sep = "\t")

      totalData[[a]] = currentFileData
      names(totalData)[a] = currentFileToOpen
    }

  commonData = data.frame(matrix(ncol = 4, nrow = nrow(totalData[[1]]) - 1), stringsAsFactors = FALSE)

  commonData = totalData[[1]][, c("Area", "X", "X", "Y", "Y", "Circ.",	"Round", "Solidity")]
  commonData = commonData[-nrow(commonData),]
  colnames(commonData) = c("Area", "Centroid_X", "Centroid_X_rescaled", "Centroid_Y", "Centroid_Y_rescaled", "Circularity", "Roundness", "Solidity")

  scale_max = 10000
  scale_min = 1


  commonData$Centroid_Y = (-1 * commonData$Centroid_Y) + max(commonData$Centroid_Y)

  commonData$Centroid_X_rescaled = (((scale_max - scale_min) / (max(commonData$Centroid_X) - min(commonData$Centroid_X))) * (commonData$Centroid_X - max(commonData$Centroid_X))) + scale_max

  commonData$Centroid_Y_rescaled = (((scale_max - scale_min) / (max(commonData$Centroid_Y) - min(commonData$Centroid_Y))) * (commonData$Centroid_Y - max(commonData$Centroid_Y))) + scale_max


  # plot(commonData$Centroid_X, commonData$Centroid_Y)
  # plot(commonData$Centroid_X_rescaled, commonData$Centroid_Y_rescaled)


  finalFluoMeanData = data.frame(matrix(ncol = length(totalData), nrow = nrow(totalData[[1]]) - 1), stringsAsFactors = FALSE)

  finalFluoIntDenData = data.frame(matrix(ncol = length(totalData), nrow = nrow(totalData[[1]]) - 1), stringsAsFactors = FALSE)

  finalCTCFData = data.frame(matrix(ncol = length(totalData), nrow = nrow(totalData[[1]]) - 1), stringsAsFactors = FALSE)

  foreach::foreach(b = 1:length(totalData)) %do%
    {
      currentFileData = totalData[[b]]
      currentFileName = names(totalData)[b]
      currentFileLabel = gsub("^quantification_([^_]+)_([^_]+)_([^_]+)_(.+)$", "\\1", currentFileName)
      currentFileFluorochrome = gsub("^quantification_([^_]+)_([^_]+)_([^_]+)_(.+)$", "\\2", currentFileName)

      currentFileColor = gsub("^quantification_([^_]+)_([^_]+)_([^_]+)_(.+)$", "\\3", currentFileName)

      currentFileSample = gsub("^quantification_([^_]+)_([^_]+)_([^_]+)_(.+)$", "\\4", currentFileName)

      currentFileMeanFluoBackground = as.numeric(currentFileData[nrow(currentFileData), "Mean"])

      currentFileCTCF = as.numeric(currentFileData$IntDen) - (as.numeric(currentFileData$Area) * currentFileMeanFluoBackground) + 10
      currentFileCTCF = currentFileCTCF[-length(currentFileCTCF)]


      currentFileFluoIntDen = as.numeric(currentFileData$IntDen)
      currentFileFluoIntDen = currentFileFluoIntDen[-length(currentFileFluoIntDen)]

      currentFileFluoMean = as.numeric(currentFileData$Mean)
      currentFileFluoMean = currentFileFluoMean[-length(currentFileFluoMean)]


      currentFileCTCFColumnTitle = paste("CTCF_", currentFileLabel, sep = "")

      finalCTCFData[, b] = currentFileCTCF
      colnames(finalCTCFData)[b] = currentFileCTCFColumnTitle

      currentFileFluoIntDenColumnTitle = paste("IntegratedDensity_", currentFileLabel, sep = "")

      finalFluoIntDenData[, b] = currentFileFluoIntDen
      colnames(finalFluoIntDenData)[b] = currentFileFluoIntDenColumnTitle

      currentFileFluoMeanColumnTitle = paste("Mean_", currentFileLabel, sep = "")

      finalFluoMeanData[, b] = currentFileFluoMean
      colnames(finalFluoMeanData)[b] = currentFileFluoMeanColumnTitle

    }

  finalTotalData = cbind(commonData, finalFluoMeanData, finalFluoIntDenData, finalCTCFData)

  finalTotalData = as.matrix(finalTotalData)


  # you need to prepare some metadata
  meta = data.frame(name = dimnames(finalTotalData)[[2]], desc = dimnames(finalTotalData)[[2]])
  meta$range <- apply(apply(finalTotalData,2,range),2,diff)
  meta$minRange <- apply(finalTotalData,2,min)
  meta$maxRange <- apply(finalTotalData,2,max)


  # a flowFrame is the internal representation of a FCS file
  methods::getClassDef(Class = "flowFrame", package = "flowCore")
  finalData_flowframe = methods::new("flowFrame", exprs = finalTotalData, parameters = Biobase::AnnotatedDataFrame(meta))
  finalFCS_filename = gsub("([^.]+)\\.(.+)", "\\1", currentFileSample)

  # now you can save it back to the filesystem
  flowCore::write.FCS(finalData_flowframe, file.path("5_analyzeROI", "output", paste(finalFCS_filename, ".fcs", sep = "")))




}
