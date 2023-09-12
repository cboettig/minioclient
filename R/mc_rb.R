#' Remove an S3 bucket using mc command
#'
#' @param bucket Character string specifying the name of the bucket to remove
#' @param force Delete bucket without confirmation in non-interactive mode
#' @inherit mc return
#'
#' @examplesIf interactive()
#' 
#' # Create a new bucket named "my-bucket" on the "play" system
#' mc_mb("play/my-bucket")
#' mc_rb("play/my-bucket")
#'
#' @export
mc_rb <- function(bucket, force = FALSE) {
  if(interactive()){
    proceed <- utils::askYesNo("Are you sure?")
  } else {
    proceed = force
    if(!proceed) {
      message("Run `mc_rb()` interactively or with force=TRUE")
    }
  }
  
  if(!proceed){ 
    return(invisible(NULL))
  }
    
  mc(paste("rb --force", bucket))
}
