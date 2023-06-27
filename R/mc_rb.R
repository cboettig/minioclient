#' Remove an S3 bucket using mc command
#'
#' @param bucket Character string specifying the name of the bucket to remove
#' @inherit mc return
#'
#' @examplesIf interactive()
#' 
#' # Create a new bucket named "my-bucket" on the "play" system
#' mc_mb("play/my-bucket")
#' mc_rb("play/my-bucket")
#'
#' @export
mc_rb <- function(bucket) {
  mc(paste("rb --force", bucket))
}
