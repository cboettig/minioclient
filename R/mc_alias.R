
#' mc alias set
#' 
#' Set a new alias for the minio client, possibly using env var defaults.
#' @param alias a short name for this endpoint, default is `minio`
#' @param access_key access key (user), reads from AWS env vars by default
#' @param secret_key secret access key, reads from AWS env vars by default
#' @param scheme https or http (e.g. for local machine only)
#' @param endpoint the endpoint domain name
#' @inherit mc return
#' @references <https://min.io/docs/minio/linux/reference/minio-mc.html>.
#' Note that keys can be omitted for anonymous use.
#' 
#' @examplesIf interactive()
#' 
#' mc_alias_set()
#' 
#' @export
mc_alias_set <- 
  function(alias = "minio", 
           endpoint = Sys.getenv("AWS_S3_ENDPOINT", "s3.amazonaws.com"),
           access_key = Sys.getenv("AWS_ACCESS_KEY_ID"),
           secret_key = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
           scheme = "https"
           ){

    cmd <- glue::glue("alias set {alias} {scheme}://{endpoint}")
    if(nchar(secret_key) > 0)
      cmd <- glue::glue(cmd, " {access_key} {secret_key}")
    mc(cmd)
  }

#' List all configured aliases
#' @param alias optional argument, display only specified alias
#' @return Configured aliases, including secret keys!
#' @seealso mc
#' @details Note that all available 
#' @export
mc_alias_ls <- function(alias = "") {
  mc(paste("alias ls", alias))
}

