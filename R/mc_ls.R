#' List files and directories using mc command
#'
#' This function uses the `mc` command to list files and directories
#'  at the specified target location.
#'
#' @param target Character string specifying the target directory path.
#' @param recursive Logical indicating whether to recursively list directories.
#'  Default is \code{FALSE}.
#' @param flags Additional flags to be passed to the `ls` command.
#'  Default is an empty string.
#' @inherit mc return
#'
#' @examplesIf interactive()
#' 
#' # list all buckets on play server
#' mc_ls("play/")
#'
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
