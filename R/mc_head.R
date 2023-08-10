#' Display first few lines of an object
#'
#' The head command returns the first n lines of the object as a string. This can 
#' be useful when inspecting the content of a large file (without first having to
#' download and store it on disk locally).
#'
#' @param target character string specifying the target directory path.
#' @param n integer number of lines to read from the beginning, by default 10
#' @param flags additional flags to be passed to the `cat` command.
#'  Default is an empty string.
#' @returns a character string with the contents of the file
#' @exampleIf interactive()
#' # upload a CSV file
#' install_mc()
#' tf <- tempfile()
#' write.csv(iris, tf, row.names = FALSE)
#' mc_mb("play/iris")
#' mc_cp(tf, "play/iris/iris.csv")
#' 
#' # read first 13 lines from the CSV (header + 12 rows of data)
#' read.csv(text = mc_head("play/iris/iris.csv", n = 13))
#' @export

mc_head <- function(target, n = 10, flags = "") {
  
  if (n != 10) {
    flags <- paste("--lines", n)
  }
  
  cmd <- paste("head", flags, target)
  cmd <- gsub("\\s+", " ", cmd)
  res <- mc(cmd, verbose = FALSE)
  
  res$stdout

}
