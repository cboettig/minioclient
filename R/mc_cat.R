#' Display object contents
#'
#' The cat command returns the contents of the object as a string. This can 
#' be useful when reading smaller files (without first downloading to disk).
#'
#' @param target character string specifying the target directory path.
#' @param offset start offset, default 0 if not specified
#' @param tail tail number of bytes at ending of file, default 0 if not specified
#' @param flags additional flags to be passed to the `cat` command.
#'  Default is an empty string.
#' @returns a character string with the contents of the file
#' @examples \dontrun{
#' mc_cat("play/email/password_reset.html")
#' }
#' @export

mc_cat <- function(target, offset = 0, tail = 0, flags = "") {
  
  if (offset != 0) {
    flags <- paste("--offset", offset)
  }
  
  if (tail != 0) {
    flags <- paste(flags, "--tail", tail)
  }
  
  cmd <- paste("cat", flags, target)
  cmd <- gsub("\\s+", " ", cmd)
  res <- suppressMessages(mc(cmd))
  
  con <- textConnection(encoding = "UTF-8", object = suppressMessages(
    res$stdout
  ))
  
  on.exit(close(con))
  
  out <- readLines(con)
  paste(collapse = "\n", out)
}
