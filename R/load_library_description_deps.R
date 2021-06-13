##' .. content for \description{} (no empty lines) ..
##'
##' .. content for ..
##'
##' @title Load all libraries in the DESCRIPTION file
##' @details
##' `remotes::dev_package_deps` used to read DESCRIPTION file.
##' NB: Assumes magrittr, remotes, dplyr, stringr already installed.
##' 
#' Default: This step (load packages) is automatically inserted at the top of  _targets.R files
#' produced by tar_script() if library_targets is TRUE,
#' so you do not need to explicitly include it in code.
##' @return TRUE if successful.
##' @author jg
##' @export
load_library_description_deps <- function() {
  
  suppressMessages(suppressPackageStartupMessages({
    # get package names from DESCRIPTION file in current working directory. 
    `%>%` <- magrittr::`%>%`
    pkgs <- remotes::dev_package_deps(dependencies = TRUE) %>% 
      dplyr::pull(package) %>% 
      stringr::str_replace_all("'", '') %>% 
      stringr::str_replace_all("\\\"", '')
    # WARNING: purrr::walk/base::lapply(pkgs, library ... FAILS targets
    # https://github.com/rstudio/renv/issues/143
    base::sapply(pkgs, library, character.only = TRUE, quiet = TRUE,
      logical.return = TRUE, warn.conflicts = FALSE) #  %>% print()
    # purrr::walk(pkgs, library, character.only = TRUE, warn.conflicts = TRUE, quietly = TRUE)
    # renv::install('pacman') ;library(pacman) ; p_load(pkgs)
  }))
  
  # conflicted
  suppressMessages({
    conflicted::conflict_prefer("as.zoo.data.frame", "quantmod") # , "zoo"
    conflicted::conflict_prefer("select", "dplyr")
    conflicted::conflict_prefer("col_factor", "readr", "scales")
    conflicted::conflict_prefer("spec", "readr", "yardstick")
    conflicted::conflict_prefer("discard", "purrr", "scales")
    conflicted::conflict_prefer("collapse", "dplyr", "glue")
    conflicted::conflict_prefer("filter", "dplyr", "stats")
    conflicted::conflict_prefer("lag", "dplyr", "stats")
    conflicted::conflict_prefer("fixed", "recipes", "stringr")
  })
  
  pkgs
}