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
#' @return [processx::run()] list, with components `status`, `stdout`,
#'  `stderr`, and `timeout`.
#' @export 
#' @details 
#' 
#' This function forms the basis for all other available commands.
#' This utility can run any `mc` command supported by the official minio client, 
#' see <https://min.io/docs/minio/linux/reference/minio-mc.html>.
#' The R package provides wrappers only for the most common use cases,
#' which provide a more natural R syntax and native documentation.
mc <- function(command, ..., path = bin_path(), verbose = TRUE) {
  
  binary <- fs::path(path, "mc")
  if(!file.exists(binary)) {
    install_mc()
  }
  
  args <- strsplit(command, split = " ")[[1]]
  p <- processx::run(binary, args, ...)
  
  if(p$timeout & verbose) warning(paste("request", command, "timed out"))
  if(p$status != 0) stop(paste(p$stderr))
  
  if(verbose) message(paste0(p$stdout))
  invisible(p)
}

