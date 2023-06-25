
#' move or rename files or directories between servers
#' 
#' @param from Character string specifying the source file or directory path.
#' Can accept a vector of file paths as well.
#' @param to Character string specifying the destination path.
#' @param recursive Logical indicating whether to recursively move directories. Default is \code{FALSE}.
#' @param flags any additional flags to `mv`
#' @param verbose Logical indicating whether to report files copied. Default is \code{FALSE}.
#' @return None
#' @details see `mc("mv -h")` for details.
#' @seealso mc_cp
#' @examples
#' \dontrun{
#' # move a file
#' mc_mv("local/path/to/file.txt", "alias/bucket/path/file.txt")
#'
#' # move a directory recursively
#' mc_mv("local/directory", "alias/bucket/path/to/directory", recursive = TRUE)
#' }
#'
#' @export
mc_mv <- function(from, to, recursive = FALSE, flags="", verbose = FALSE) {
  if(recursive) {
    flags <- paste("-r", flags)
  }
  
  cmd <- paste("mv", flags, from, to)
  cmd <- gsub("\\s+", " ", cmd)
  mc(cmd, verbose = verbose)
}




