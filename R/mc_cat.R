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
#' @examplesIf interactive()
#' # upload a file to a bucket and read it back
#' install_mc()
#' mc_mb("play/mcr")
#' mc_cp(system.file(package = "minioclient", "DESCRIPTION"), "play/mcr/DESCRIPTION")
#' mc_cat("play/mcr/DESCRIPTION")
#' 
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
  res <- mc(cmd, verbose = FALSE)
  
  res$stdout
  
}
