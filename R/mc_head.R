#' Display first few lines of an object
#'
#' The head command returns the first n lines of the object as a string. This can 
#' be useful when inspecting the content of a file(without first downloading to disk).
#'
#' @param target character string specifying the target directory path.
#' @param n integer number of lines to read from the beginning, by default 10
#' @param flags additional flags to be passed to the `cat` command.
#'  Default is an empty string.
#' @returns a character string with the contents of the file
#' @examples \dontrun{
#' mc_head("play/email/password_reset.html")
#' }
#' @export

mc_head <- function(target, n = 10, flags = "") {
  
  if (n != 0) {
    flags <- paste("--lines", n)
  }
  
  cmd <- paste("head", flags, target)
  cmd <- gsub("\\s+", " ", cmd)
  res <- suppressMessages(mc(cmd))
  
  con <- textConnection(encoding = "UTF-8", object = suppressMessages(
    res$stdout
  ))
  
  on.exit(close(con))
  
  readLines(con, n = n)
}
