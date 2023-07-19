#' Create a new S3 bucket using mc command
#'
#' @param bucket Character string specifying the name of the bucket to create.
#' @param ignore_existing do not error if bucket already exists
#' @param flags additional flags, see `mc_mb("-h")` for details. 
#' @inheritParams mc
#' @inherit mc return
#'
#' @examplesIf interactive()
#' 
#' # Create a new bucket named "my-bucket"
#' mc_mb("play/my-bucket")
#'
#' @export
mc_mb <- function(bucket,
                  ignore_existing = TRUE,
                  flags = "", verbose = TRUE) {
  
  if(ignore_existing) {
    flags <- paste("--ignore-existing", flags)
  }
  
  cmd <- paste("mb", flags, bucket)
  cmd <- gsub("\\s+", " ", cmd)
  
  mc(cmd, verbose = verbose)
}
