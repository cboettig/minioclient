#' Create a new S3 bucket using mc command
#'
#' @param bucket Character string specifying the name of the bucket to create.
#'
#' @examples
#' \dontrun{
#' # Create a new bucket named "my-bucket"
#' mc_mb("play/my-bucket")
#' }
#'
#' @export
mc_mb <- function(bucket) {
  mc(paste("mb", bucket))
}
