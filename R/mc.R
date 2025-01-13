#' mc 
#' 
#' The MINIO Client
#' 
#' @param command space-delimited text string of an mc command
#'  (starting after the mc ...)
#' @param ... additional arguments to [processx::run()]
#' @param path location where mc executable will be installed. By default will
#' use the OS-appropriate storage location.  
#' @param verbose print output?
#' @return Returns the list from [processx::run()], with components `status`, 
#' `stdout`, `stderr`, and `timeout`; invisibly.
#' @export 
#' @details 
#' 
#' This function forms the basis for all other available commands.
#' This utility can run any `mc` command supported by the official minio client, 
#' see <https://min.io/docs/minio/linux/reference/minio-mc.html>.
#' The R package provides wrappers only for the most common use cases,
#' which provide a more natural R syntax and native documentation.
mc <- function(command, ..., path = minio_path(), verbose = interactive()) {
  binaryname <- "mc"
  if (.Platform$OS.type == "windows") {
    binaryname <- "mc.exe"
  }
  binary <- fs::path(path, "mc")
  if(!file.exists(binary) && interactive()) {
    proceed <- utils::askYesNo(
      "the mc client is not yet installed, should we install it now?")
    if(proceed) install_mc()
  }
  
  command <- paste("--config-dir", shQuote(path), command)
  args <- scan(text = command, what = 'character', quiet = TRUE)
  p <- processx::run(binary, args, ...)
  
  if(p$timeout & verbose) warning(paste("request", command, "timed out"))
  if(p$status != 0) stop(paste(p$stderr))
  
  if(verbose) message(paste0(p$stdout))
  invisible(p)
}

