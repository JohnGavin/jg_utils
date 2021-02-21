## ---- load_libss

load_libs <- function(pkgs){
  suppressPackageStartupMessages({
    sapply(pkgs, require, character.only=TRUE, 
      quietly=FALSE, warn.conflicts=FALSE
      # , mask.ok = list(
      #   magrittr = c('set_names', # package:purrr
      #     'extract'), # package:tidyrr
      #   tibble = TRUE # c('has_name') # package:tibble
      #   #, tidyverse = TRUE # c('has_name') # package:tibble
      #   , assertthat = TRUE # c('has_name') # package:tibble
      # ) 
    )
    # library(magrittr) ; pkgs %>% sapply ...?
  }) -> ret
  
  missing_pkgs <- sort(names(which(ret == FALSE)))
  if (length(missing_pkgs) > 0) {
    warning("The following packages are not installed: %s", 
      paste0(sprintf("  - %s", missing_pkgs), collapse="\n"))
  }
  # alternative?
  # if (!"pacman" %in% installed.packages()[,"Package"]) 
  #   install.packages("pacman", repos='http://cran.r-project.org')
  # pacman::p_load(
  #   tidyverse,rdbnomics,magrittr,zoo,lubridate,knitr,kableExtra,formattable)
}
