#' Shiny app allowing the interactive use of PUPAID workflow
#'
#' This Shiny app can be used instead of the classical script approach in order to use PUPAID. It will open a new window which will present the overall workflow of PUPAID. It is composed of buttons to automatically launch the necessary functions as well as text inputs to enter requested values. It also gives advice and tips about the analysis workflow and how to correctly use it. This application is ideal for beginners or for people who are not fluent with R programming or programming in general.
#'
#' @export

interactivePUPAID = function()
{


  # Server.R

  server = function(input, output, session) {

    volumes = shinyFiles::getVolumes()() # this makes the directory at the base of your computer.
    shiny::observe({
      shinyFiles::shinyDirChoose(input, 'workingDirectory', roots=volumes)
      shinyFiles::shinyFileChoose(input, 'imageJPath', roots=volumes)
      # print(paste(unlist(input$folder)[-1], collapse = .Platform$file.sep))
      wdPath = shinyFiles::parseDirPath(roots=volumes, selection = input$workingDirectory)
      wdPath = as.character(wdPath)
      if(length(wdPath) > 0)
      {
        setwd(wdPath)

        output$workingDirectory_print = shiny::renderPrint({getwd()})
      }
      # print(normalizePath("~"))
      # print(file.path(paste(unlist(input$folder$path[-1]), collapse = .Platform$file.sep)))

      imageJPath = shinyFiles::parseFilePaths(roots=volumes, selection = input$imageJPath)
      imageJPath = as.character(imageJPath[4])
      if(length(imageJPath) > 0)
      {

        output$imageJPath_print = shiny::renderPrint({imageJPath})
        session$userData$imageJPath = imageJPath
      }

      session$userData$radius = input$radius

      session$userData$maxSigmaRatio = input$maxSigmaRatio
      session$userData$step = input$step
      session$userData$sigmaLow = input$sigmaLow
      session$userData$sigmaHigh = input$sigmaHigh
    })





    #####


    shiny::observeEvent(input$createWorkspace, {
      PUPAID::createWorkspaceStructure(wd = getwd())
      print("Create workspace: done!")
    })

    shiny::observeEvent(input$generateBlackTile, {
      PUPAID::runMacro_generateBlackTile(imageJPath = session$userData$imageJPath, wd = getwd())
      print("Generate black tile: done!")

    })

    shiny::observeEvent(input$getImageSize, {
      imageSize = runMacro_getImageSize(imageJPath = session$userData$imageJPath, wd = getwd())
      print("Get image size: done!")
      print(imageSize)
      session$userData$imageSize = imageSize
    })

    shiny::observeEvent(input$renameAndOrderTiles, {
      print("Warning: this step might be long. Please wait for the \"Rename and order tiles: done!\" message to appear in the R console.")
      renameAndOrderOutput = PUPAID::renameAndOrderTiles(AOI_x = session$userData$imageSize[1], AOI_y = session$userData$imageSize[2])
      print("Rename and order tiles: done!")
      session$userData$renameAndOrderOutput = renameAndOrderOutput
    })

    shiny::observeEvent(input$stitchTiles, {
      print("Warning: this step might be long. Please wait for the \"Stitch tiles: done!\" message to appear in the R console.")
      PUPAID::stitchTiles(renameAndOrderOutput = session$userData$renameAndOrderOutput, imageJPath = session$userData$imageJPath, wd = getwd())
      print("Stitch tiles: done!")
    })

    shiny::observeEvent(input$openImageJ, {
      system(session$userData$imageJPath)
      print(session$userData$imageJPath)
    })

    shiny::observeEvent(input$openImageJ2, {
      system(session$userData$imageJPath)
      print(session$userData$imageJPath)
    })

    shiny::observeEvent(input$generateSigmaPairs, {
      # print(session$userData$step)
      sigmaPairsToTest = PUPAID::generateSigmaPairsList(radius = as.numeric(session$userData$radius), maxSigmaRatio = as.numeric(session$userData$maxSigmaRatio), step = as.numeric(session$userData$step))
      print("Generate sigma pairs: done!")
      print(sigmaPairsToTest)
      session$userData$sigmaPairsToTest = sigmaPairsToTest
    })

    shiny::observeEvent(input$benchmarkSigmaPairs, {
      # print(session$userData$step)
      print("Warning: this step might be long. Please wait for the \"Benchmark sigma pairs: done!\" message to appear in the R console.")
      PUPAID::benchmarkSigmaPairs(imageJPath = session$userData$imageJPath, wd = getwd(), sigmaPairsToTest = session$userData$sigmaPairsToTest)
      print("Benchmark sigma pairs: done!")
    })

    shiny::observeEvent(input$analyzeROI, {
      # print(session$userData$step)
      PUPAID::runMacro_analyzeROI(imageJPath = session$userData$imageJPath, wd = getwd(), sigmaLow = session$userData$sigmaLow, sigmaHigh = session$userData$sigmaHigh)
      print("Generate macro for the final ROI analysis: done!")

    })

    shiny::observeEvent(input$mergeTSVtoFCS, {

      PUPAID::mergeTSVtoFCS()
      print("Merge all TSV files to a single FCS file: done!")
    })


    shiny::observeEvent(input$convertTSVtoXLSX, {

      PUPAID::convertTSVtoXLSX()
      print("Convert TSV files to XLSX files: done!")
    })
  }

  # UI.R


  ui = shiny::fluidPage(
    shiny::HTML("<h1><b>PUPAID Interactive Control Panel</b></h1>"),

    shiny::HTML("<h3><b>1) <u>Preliminary setup</u></b></h3>"),

    shiny::HTML("<h5><b>1.1) <u>Select the working directory folder</u></b></h5>"),

    shinyFiles::shinyDirButton("workingDirectory", "Select a folder", "Please select a folder", FALSE),
    shiny::verbatimTextOutput("workingDirectory_print"),

    shiny::HTML("<br/><h5><b>1.2) <u>Select the path to ImageJ executable</u></b></h5>"),

    shinyFiles::shinyFilesButton("imageJPath", "Select ImageJ Path", "Please select a folder", FALSE),
    shiny::verbatimTextOutput("imageJPath_print"),

    shiny::HTML("<br/><h5><b>1.3) <u>Create the workspace</u></b></h5>"),

    shiny::actionButton("createWorkspace", "Create workspace"),

    shiny::HTML("<h3><b>2) <u>Pre-processing</u></b></h3>"),

    shiny::HTML("<h5><b>2.1) <u>Generate the black tile</u></b></h5>"),

    shiny::HTML("<p>Before clicking the next button, please place one of the tiles of interest in the <em>1_generateBlackTile > input</em> folder.</p>"),

shiny::actionButton("generateBlackTile", "Generate black tile"),

shiny::HTML("<br/><br/><h5><b>2.2) <u>Get the image size</u></b></h5>"),

    shiny::actionButton("getImageSize", "Get image size"),
shiny::HTML("<br/><br/><h5><b>2.3) <u>Rename and order tiles</u></b></h5>"),

shiny::HTML("<p>Before clicking the next button, please place all the tiles of interest in the <em>2_renameAndOrderTiles > input</em> folder</p>"),

    shiny::actionButton("renameAndOrderTiles", "Rename and order tiles"),


shiny::HTML("<br/><br/><h5><b>2.4) <u>Stitch tiles</u></b></h5>"),

    shiny::actionButton("stitchTiles", "Stitch tiles"),


shiny::HTML("<br/><br/><h5><b>2.5) <u>Manually measure the overall cell diameter and crop one stitch of interest</u></b></h5>"),
shiny::HTML("<p>Once ImageJ is launched, you have to open of the freshly generated stitched images located in the <em>3_stitchedTiles</em> folder in order to 1) estimate the maximum cell diameter using any built-in ImageJ tool you prefer (usually the <em>Straight selection tool</em> is sufficient for this task) and 2) crop this image to a smaller area (typically several hundreds pixels wide) and save this new image as a TIFF using the built-in ImageJ tools. At the end, please write the overall cell diameter in the <em>Cell radius</em> textbox below, which will serve for the upcoming cell segmentation, and finally close the launched ImageJ instance.</p>"),

    shiny::actionButton("openImageJ2", "Open ImageJ"),


shiny::HTML("<br/><br/><h5><b>2.6) <u>Generate the list of sigma pairs to test for the Difference of Gaussians cell segmentation</u></b></h5>"),



    shiny::textInput("radius", "Cell radius (in micrometers)", value = "", width = NULL, placeholder = NULL),
    shiny::textInput("maxSigmaRatio", "Maximum sigma ratio", value = "2", width = NULL, placeholder = NULL),
    shiny::textInput("step", "Step", value = "0.1", width = NULL, placeholder = NULL),

shiny::actionButton("generateSigmaPairs", "Generate sigma pairs to test"),


shiny::HTML("<br/><br/><h5><b>2.7) <u>Benchmark the generated list of sigma pairs</u></b></h5>"),
shiny::HTML("<p>Before clicking the next button, please place a stitched ROI (or cropped version of it if you want to decrease computation time and resources) <b><u>only</u></b> containing the signal that you want to use for cell segmentation (typically nuclear staining such as DAPI) in the <em>4_testSigmaPair > input</em> folder.</p>"),


    shiny::actionButton("benchmarkSigmaPairs", "Benchmark sigma pairs to test"),


shiny::HTML("<h3><b>3) <u>Analysis</u></b></h3>"),

shiny::HTML("<h5><b>3.1) <u>Generate the macro to use for the final analysis</u></b></h5>"),

shiny::HTML("<p>Please visualize the freshly generated benchmark for cell segmentation and enter below the best <em>sigmaLow</em> and <em>sigmaHigh</em> values to use for the final cell segmentation on the full stitched image.</p>"),



    shiny::textInput("sigmaLow", "Sigma low to use", value = "", width = NULL, placeholder = NULL),
    shiny::textInput("sigmaHigh", "Sigma high to use", value = "", width = NULL, placeholder = NULL),

shiny::actionButton("analyzeROI", "Generate macro to analyze ROI"),


shiny::HTML("<br/><br/><h5><b>3.2) <u>Launch ImageJ and run the analysis</u></b></h5>"),
shiny::HTML("<p>Before clicking on the next button, please place the stitched ROI you want to analyze in the <em>5_analyzeROI > input</em> folder. Additionally, please note that due to some technical limitations, this interactive application cannot directly launch the previously generated ImageJ macro. Instead, click on the button below to open ImageJ and manually go to <em>Plugins > Macros > Run...</em> and select the newly generated macro file named <em>5_analyzeROI_run.txt</em> and located in the <em>macros</em> directory.</p>"),


    shiny::actionButton("openImageJ", "Open ImageJ"),


shiny::HTML("<br/><br/><h5><b>3.3) <u>Convert TSV files to XLSX</u></b></h5>"),

    shiny::actionButton("convertTSVtoXLSX", "Convert TSV files to XLSX"),


shiny::HTML("<br/><br/><h5><b>3.4) <u>Merge TSV files to FCS</u></b></h5>"),

    shiny::actionButton("mergeTSVtoFCS", "Merge TSV files to FCS"),

shiny::HTML("<br/><br/>"),

shiny::HTML("<p>If you have other ROI to analyze with the same macro, please proceed from the step 3.2), but do not forget to move the content of the <em>5_analyzeROI > output</em> folder elsewhere to avoid any overwriting.</p>")

  )


  shiny::shinyApp(ui = ui, server = server)

}
