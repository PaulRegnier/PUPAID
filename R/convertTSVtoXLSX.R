#' Convert TSV files to XLSX files
#'
#' This function converts every TSV file found in the `5_analyzeROI > output` directory into their respective XLSX files.#'
#'
#' @importFrom foreach %do%
#'
#' @export

convertTSVtoXLSX = function()
{

  a = NULL

  filesToImport = list.files(file.path("5_analyzeROI", "output"), pattern = "*.tsv")

  foreach::foreach(a = 1:length(filesToImport)) %do%
    {
      currentFileToOpen = filesToImport[a]
      currentFileData = data.table::fread(file.path("5_analyzeROI", "output", currentFileToOpen), sep = "\t")
      currentFileData = data.frame(currentFileData)

      colnames(currentFileData)[1] = "Cell"

      writexl::write_xlsx(currentFileData, path = gsub("\\.tsv", ".xlsx", file.path("5_analyzeROI", "output", currentFileToOpen)), col_names = TRUE)
    }


}


