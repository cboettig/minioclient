#' mc 
#' 
#' The MINIO Client
#' 
#' @param command text string of an mc command (starting after the mc ...)
#' @param ... additional arguments (not used)
#' @param path location where mc executable will be installed. By default will
#' use the OS-appropriate storage location.  
#' @export 
#' @details see <https://docs.min.io/docs/minio-client-quickstart-guide.html>

# FIXME consider using processx -- why doesn't it work?
mc <- function(command, ..., path = bin_path()) {
  binary <- fs::path(path, "mc")
  system2(binary, command)
  
  # FIXME why can't we use processx instead?
  #cmd <- paste(binary, command)
  #pid <- processx::run(cmd)
  
}


#' mc alias set
#' 
#' Set a new alias for the minio client, possibly using env var defaults.
#' @param alias a short name for this endpoint, default is `minio`
#' @param access_key accesss key (user), will be read from AWS env vars by default
#' @param secret_key secret access key, will be read from AWS env vars by default
#' @param scheme https or http (e.g. for local machine only)
#' @param endpoint the endpoint domain name
#' @details see <https://docs.min.io/docs/minio-client-quickstart-guide.html#add-a-cloud-storage-service>
#' @export
mc_alias_set <- 
    function(alias = "minio", 
             access_key = Sys.getenv("AWS_ACCESS_KEY_ID"),
             secret_key = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
             scheme = "https",
             endpoint = Sys.getenv("AWS_S3_ENDPOINT",
                                            "s3.amazonaws.com")){
  
  
  cmd <- glue::glue(
    "alias set {alias} {scheme}://{endpoint} '{access_key}' '{secret_key}'")
  mc(cmd)

  
  
  
  }
           