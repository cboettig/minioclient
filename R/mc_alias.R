
#' mc alias set
#' 
#' Set a new alias for the minio client, possibly using env var defaults.
#' @param alias a short name for this endpoint, default is `minio`
#' @param access_key access key (user), will be read from AWS env vars by default
#' @param secret_key secret access key, will be read from AWS env vars by default
#' @param scheme https or http (e.g. for local machine only)
#' @param endpoint the endpoint domain name
#' @details see <https://docs.min.io/docs/minio-client-quickstart-guide.html#add-a-cloud-storage-service>.
#' Note that keys can be omitted for anonymous use.
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
mc_alias_ls <- function(alias = "") {
  mc(paste("alias ls", alias))
}

