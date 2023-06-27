
#' Mirror files and directories using mc command
#'
#' This function uses the `mc` command to mirror files and directories
#'  from one location to another.
#'
#' @param from Character string specifying the source file or directory path.
#' @param to Character string specifying the destination path.
#' @param overwrite Logical indicating whether to overwrite existing files.
#'  Default is \code{FALSE}.
#' @param remove Logical indicating whether to remove extraneous files from
#'  the destination. Default is \code{FALSE}.
#' @param flags Additional flags to be passed to the `mirror` command.
#'  Default is an empty string.
#' @param verbose Logical indicating whether to display verbose output.
#'  Default is \code{FALSE}.
#'
#' @inherit mc return
#'
#' @examplesIf FALSE
#'
#' # Mirror files and directories from source to destination
#' mc_mirror("path/to/source", "path/to/destination")
#'
#' # Mirror files and directories with overwrite and remove options
#' mc_mirror("path/to/source", "path/to/destination",
#'            overwrite = TRUE, remove = TRUE)
#'
#' # Mirror files and directories with additional flags and verbose output
#' mc_mirror("path/to/source", "path/to/destination", 
#'           flags = "--exclude '*.txt'", verbose = TRUE)
#'
#' @export
mc_mirror <- function(from, to, overwrite = FALSE, 
                      remove = FALSE, flags = "", verbose = FALSE) {
  if (overwrite) {
    flags <- paste("--overwrite", flags)
  }
  if (remove) {
    flags <- paste("--remove", flags)
  }
  cmd <- paste("mirror", flags, from, to)
  cmd <- gsub("\\s+", " ", cmd)
  mc(cmd, verbose = verbose)
}
