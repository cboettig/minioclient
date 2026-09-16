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
  
  binary <- fs::path(path, mc_bin())
  if(!file.exists(binary) && interactive()) {
    proceed <- utils::askYesNo(
      "the mc client is not yet installed, should we install it now?")
    if(proceed) install_mc()
  }
  
  command <- paste("--config-dir", shQuote(path), command)
  args <- scan(text = command, what = 'character', quiet = TRUE)
  # error_on_status = FALSE so the status check below can surface mc's own
  # stderr; otherwise processx throws first and the server's message is buried
  # in a generic "System command 'mc' failed". A caller who passes
  # error_on_status through ... still wins.
  dots <- list(...)
  if (is.null(dots$error_on_status)) {
    dots$error_on_status <- FALSE
  }
  p <- do.call(processx::run, c(list(binary, args), dots))
  
  if(isTRUE(p$timeout) && verbose) warning(paste("request", command,
                                                 "timed out"))
  # Suppressing processx's own error means a timeout or interrupt now lands
  # here too, with a status of NA and possibly nothing on stderr.
  if (!identical(as.integer(p$status), 0L)) {
    msg <- paste(p$stderr, collapse = "\n")
    if (!nzchar(trimws(msg))) {
      msg <- if (isTRUE(p$timeout)) {
        paste("mc", command, "timed out")
      } else {
        paste("mc", command, "failed with status", p$status)
      }
    }
    stop(msg, call. = FALSE)
  }
  
  if(verbose) message(paste0(p$stdout))
  invisible(p)
}

