#' List files and directories using mc command
#'
#' This function uses the `mc` command to list files and directories at the specified target location.
#'
#' @param target Character string specifying the target directory path.
#' @param recursive Logical indicating whether to recursively list directories. Default is \code{FALSE}.
#' @param flags Additional flags to be passed to the `ls` command. Default is an empty string.
#' @return list of files
#'
#' @examples
#' \dontrun{
#' # List files and directories in a directory
#' mc_ls("path/to/directory")
#'
#' # List files and directories recursively in a directory
#' mc_ls("path/to/directory", recursive = TRUE)
#'
#' # List files and directories with additional flags
#' mc_ls("path/to/directory", flags = "-l")
#' }
#'
#' @export
mc_ls <- function(target, recursive = FALSE, flags = "") {
  if (recursive) {
    flags <- paste("--recursive", flags)
  }
  cmd <- paste("ls", flags, target)
  cmd <- gsub("\\s+", " ", cmd)
  mc(cmd)
}
