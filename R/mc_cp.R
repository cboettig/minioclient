
#' Copy files or directories between servers
#'
#' Most commonly used to upload and download files between local filesystem
#'  and remote S3 store.
#' 
#' @param from Character string specifying the source file or directory path.
#' Can accept a vector of file paths as well.
#' @param to Character string specifying the destination path.
#' @param recursive Logical indicating whether to recursively copy directories.
#'  Default is \code{FALSE}.
#' @param flags any additional flags to `cp`
#' @param verbose Logical indicating whether to report files copied.
#'  Default is \code{FALSE}.
#' @return None
#' @details see `mc("cp -h")` for details.
#' @seealso `mc_mirror`
#' @examples
#' \dontrun{
#' # Copy a file
#' mc_cp("local/path/to/file.txt", "alias/bucket/path/file.txt")
#'
#' # Copy a directory recursively
#' mc_cp("local/directory", "alias/bucket/path/to/directory", recursive = TRUE)
#' }
#'
#' @export
mc_cp <- function(from, to, recursive = FALSE, flags="", verbose = FALSE) {
  if(recursive) {
    flags <- paste("-r", flags)
  }
  
  cmd <- paste("cp", flags, from, to)
  cmd <- gsub("\\s+", " ", cmd)
  mc(cmd, verbose = verbose)
}




