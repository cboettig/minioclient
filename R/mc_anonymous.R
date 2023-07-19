

#' Set anonymous access policy
#'
#' This function uses the `mc` command to set the anonymous access policy for
#'  a specified target.
#'
#' @param target Character string specifying the target cloud storage
#'  bucket or object
#' @param policy Character string specifying the anonymous access policy. 
#'  Must be one of "download", "upload", "public" (upload and download),
#'  or "private".
#' @inheritParams mc
#' @inherit mc return
#'
#' @examplesIf interactive()

#' # create a test bucket on the 'play' server
#' mc_mb("play/minioclient-test")
#' 
#' # Set anonymous access policy to download
#' mc_anonymous_set("play/minioclient-test/file.txt", policy = "download")
#'
#' # Set anonymous access policy to upload
#' mc_anonymous_set("play/minioclient-test/directory", policy = "upload")
#'
#' # Set anonymous access policy to public
#' mc_anonymous_set("play/minioclient-test/file.txt", policy = "public")
#'
#' # Set anonymous access policy to private (default policy for new buckets)
#' mc_anonymous_set("play/minioclient-test/directory", policy = "private")
#'
#' mc_rb("play/minioclient-test")
#' @aliases mc_policy_set
#' @export
mc_anonymous_set <- function(target, 
                             policy = c("download", "upload", 
                                        "public", "private"),
                             verbose = interactive()) {
  policy <- match.arg(policy)
  mc(paste("anonymous set", policy, target), verbose = verbose)
}


mc_policy_set <- mc_anonymous_set
