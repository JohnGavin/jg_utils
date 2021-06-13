## ---- setup_logger_knitr.R

setup_knitr <- function(){ 

  suppressPackageStartupMessages(require(knitr))
  knitr::opts_chunk$set(
    # WARNING: set cache = FALSE   force knit to recalc mov avgs (slooow)
    # WARNING: read_cached_results force knit to recalc mov avgs (slooow)
    eval = TRUE, 
    cache = FALSE, cache.lazy = FALSE,
    tidy = FALSE, # ## NB no formatR, no "styler",  FALSE, 
    echo = FALSE, collapse = TRUE, 
    comment = "#>", #  Default is ##
    message=FALSE, warning=FALSE, error = FALSE )

  # https://www.jumpingrivers.com/blog/knitr-rmarkdown-image-size/
  # # Pixels
  # create images by specifying the exact number of pixels. 
  # library("ggplot2")
  # dd = data.frame(x = 0:10, y = 0:10)
  # g = ggplot(dd, aes(x, y)) + geom_point()
  # png("figure1-400.png", width = 400, height = 400, type = "cairo-png")
  # g
  # dev.off()
  # dim(png::readPNG("figure1-400.png", TRUE))
  # knitr::include_graphics("figure1-400.png")
  # 
  # # Dimensions
  # {knitr} can’t specify the number of pixels when creating image
  # instead set the figure dimensions and also the output dimensions.
  # The image units are hard-coded as inches within {knitr}.
  # dimensions of the image = fig.height * dpi and fig.width * dpi. 
  # (set fig.retina = 1,)
  # 
  # create an image with dimensions d1 and d2
  # fig.width = d1 / 72,
  # fig.width = d2 / 72
  # dpi = 72 - the default
  # fig.retina = 1
  # When fig.retina is set to 2, the dpi is doubled, but the display sized is halved
  # defaults for fig.retina differ between {rmarkdown} and {knitr}. 
  # So set it explicitly at the top of the document via
  # knitr::opts_chunk$set(fig.retina = 2) ## Or 1 if you want
  # Whether you set it to 1 or 2 doesn’t affect the values you set for dpi and fig. What it does affect is the size of the generated image
  # 
  # dev.args = list(type = "cairo-png") # not needed, but set it!
  # dpi value is passed to the res argument in png(), and that controls the text scaling. So changing dpi means your text changes. In practice, leave dpi at the default value. If you want to change the your text size, then change them in your plot
  # 
  # out.width and out.height don’t change the dimensions of the png created. Instead, they control the size of the HTML container on the web-page.
  # only ever define two of fig.width, fig.height and fig.asp.
  # set fig.asp = 0.7 in the {knitr} header
  # fig.width = 400/72 and fig.height = 400/72
  # https://www.jumpingrivers.com/blog/knitr-default-options-settings-hooks/
  
  dpi_tmp = if (knitr::is_latex_output()) 72 else 300
  knitr::opts_chunk$set(
    dpi = dpi_tmp ,
    # dpi = c(pdf = 300, else = 72),
    fig.width = (6 * dpi_tmp)/dpi_tmp,
    out.width = 100 , # 100%
    fig.asp = 0.7, fig.retina = 2,
    fig.align = c("center", "left")[1], 
    fig.pos = "t"
    # , fig.path = "graphics/knitr-" # create a standard directory
    )

  # # https://www.jumpingrivers.com/blog/r-knitr-markdown-png-pdf-graphics/
  # # dev.args = list(type = "cairo-png") - not actually needed, but you should set it!
  # # dev = c(pdf = "cairo_pdf" , html = = "svg")
  # dev_tmp = if (knitr::is_latex_output())
  #   c("png", "svg")[1] else "cairo_pdf"
  # knitr::opts_chunk$set(dev = dev_tmp,
  #   # when we set dev = "png", we use the cairo-png variety.
  #   dev.args = list(png = list(type = "cairo-png")))
  # 
  # # http://adamleerich.com/assets/reports-appendix/report-code-appendix.Rmd.txt
  # options(tinytex.verbose = TRUE)
  # knitr::opts_chunk$set(
  #   purl = FALSE,
  #   results=c('markup', 'hide')[2])
}


setup_logger <- function(log_folder = './logs'){
  # https://daroczig.github.io/logger/articles/customize_logger.html
  # require(logger) # should already be loaded in load_libs above?
  log_appender(appender_console, index = 1) # append to std output
  
  # create log file based on current Rmd name, in logs folder
  fp <- log_folder ; if (!dir.exists(fp)) dir.create(fp)
  # NOT getActiveDocumentContext - fails within console!
  #fn <- rstudioapi::getSourceEditorContext()$path %>% basename %>% 
  #  str_replace('(Rmd$)|(r$)|(R$)', 'log') 
# https://stackoverflow.com/questions/1815606/determine-path-of-the-executing-script
# install.packages("arrow")
# devtools::install_github('jerryzhujian9/ezR', force = TRUE)
# tmp <- ezR::ez.csf()
# log_success("End of file {basename(tmp)}\n\r\tFolder: {dirname(tmp)}")
	# fn <- basename(ezR::ez.csf()) %>% str_replace('(Rmd$)|(r$)|(R$)', 'log')
	thisFile <- function() {
        cmdArgs <- commandArgs(trailingOnly = FALSE)
        needle <- "--file="
        match <- grep(needle, cmdArgs)
        if (length(match) > 0) {
                # Rscript
                return(normalizePath(sub(needle, "", cmdArgs[match])))
        } else {
                # 'source'd via R console
                return(normalizePath(sys.frames()[[1]]$ofile))
        }
  }
  #	fn <- basename(thisFile()) %>% str_replace('(Rmd$)|(r$)|(R$)', 'log')
	fn <- 'default_filename.Rmd' %>% str_replace('(Rmd$)|(r$)|(R$)', 'log')

  fp_fn <- file.path(fp, fn)
  log_appender(appender_file(file= fp_fn), index = 2)
  log_colour <- fp_fn %>% str_replace('\\.log$', '_colour.log')
  log_appender(appender_file(file=log_colour), index = 3)
  log_threshold(DEBUG, index = 1)
  log_threshold(TRACE, index = 2)
  log_threshold(TRACE, index = 3)
  # log_threshold(index = 1) # console at debug level - switch to INFO?
  # log_threshold(index = 2) # log file at trace level
  log_layout(layout_glue_colors, index = 1) # coloured and glued console
  log_layout(layout_glue       , index = 2) # NB: _no_ colours
  log_layout(layout_glue_colors, index = 3) # NB: with colours
  #log_success("Starting log file: {fp_fn}")
  #log_info("Reset console log to from DEBUG to INFO?")
  # readLines(fp_fn) ; readLines(log_colour)
  # log_appender(index = 1) ; log_appender(index = 2) # logging to file
}
