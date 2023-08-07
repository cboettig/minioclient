
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

mc_alias_ls_env <- function(alias, details = FALSE, show_secret = FALSE) {
  envs <- Sys.getenv()[which(grepl("^MC_HOST_.*", names(Sys.getenv())))]
  aliases <- gs(names(envs), "MC_HOST_", "")
  if (!missing(alias)) aliases <- aliases[names(aliases) %in% alias]
  if (!details) return(aliases)
  parse_mc_host_env(envs, show_secret = show_secret)
}

gsr <- function(x, y, z) {
  res <- gs(x, y, z)
  vreplace(res)
}

validate_url <- function(x) {
  # TODO: fix me! ... from https://regex101.com/r/gCXX9j/1
  re_url <- paste0(
    "^(?:(http?|s?ftp):\\/\\/|file:\\/\\/\\/)?",
    "(([\\P{Cc}]+):([\\P{Cc}]+)@)?",
    "([a-zA-Z0-9][a-zA-Z0-9.-]*)(:[0-9]{1,5})?",
    ""
    # "($|\\/[\\w\\-\\._~:\\/?[\\]@!\\$&'\\(\\)\\*\\+,;=.]+(\\#[\\w]*)?$)"
  )
  re <- "^(https?)://(\\b(.*):((.*)@\\b))?(\\b[^:]*?\\b):?(\\b\\d{1,5}\\b)?(/.*?)$"
  grepl(re, x, perl = TRUE)
} 
  
parse_url <- function(x) {

  re <- "^(https?)://(\\b(.*):((.*)@\\b))?(\\b[^:]*?\\b):?(\\b\\d{1,5}\\b)?(/?.*?)$"
  
  hits <- regmatches(x, regexec(re, x))
  hit <- function(x) vreplace(sapply(hits, "[[", x))

  data.frame(
    proto = hit(2),
    user = hit(4),
    pass = hit(6),
    host = hit(7),
    port = hit(8),
    query = hit(9)
  )
}  

#' Parse a named vector containing MC_HOST_* environment variable(s)
#' 
#' In addition to known aliases against S3 servers configured in the
#' config.json file for the minio client, settings for remote connections 
#' or aliases can also be provided through system environment variables 
#' named "MC_HOST_*" using one string.
#' 
#' This function parses such a string and returns the components as a 
#' data frame.
#' 
#' @details
#' 
#' In minio parlance these settings together constitute an "alias" and the 
#' asterisk in MC_HOST_* represents a placeholder for the corresponding alias.
#' 
#' These MC_HOST_* environment variable string values are similar to database 
#' connection strings; they encode information about protocol/scheme, credentials 
#' and optional session tokens used and server host URL in a single string - 
#' ie settings required for making a connection an S3 server. 
#' 
#' @param x a named vector - where the name corresponds to the "alias"
#' @param show_secret logical indicating whether to blank out or
#' to include the secret access key (the default)
#' @return a data frame with the same columns as when 
parse_mc_host_env <- function(x, show_secret = TRUE) {
  
  # see https://github.com/minio/mc/blob/0a529d5e642f1a50a74b256c683be453e26bf7e9/cmd/config.go#L215
  
  re_proto <- "(https*)://"
  re_triplet <- "(.*?):(.*?)(:(.*?))*"
  re_rol <- "(.*?)"
  re_endpoint <- "(.*?)(:(\\b\\d{1,5}\\b))?(.*?)"

  # the full MC_HOST_var pattern
  re_all <- paste0(".*?", re_proto, re_triplet, "@", re_rol, "$")
  
  # the tail, to cater for more than 9 re capture groups
  re_tail <- paste0(".*?@", re_endpoint, "$")
  #re_tail <- ".*?@(([^:]*)(:(.*?)))?(.*?)$"

  # now parse the components
  
  alias <- gsr(names(x), "MC_HOST_", "")
  
  # triplet login/pass and (optional) token
  login <- gsr(x, re_all, "\\2")
  pass <- gsr(x, re_all, "\\3")
  token <- gsr(x, re_all, "\\5")
  
  # server info
  proto <- gsr(x, re_all, "\\1")
  endpoint <- gsr(x, re_all, "\\6")
  port <- gsr(x, re_tail, "\\3")
  
  URL <- paste0(proto, "://", endpoint, 
    ifelse(is.na(port), "", paste0(":", port)))
  
  status <- ifelse(!grepl("\\s+", URL), "success", "invalid")
  accessKey <- login
  secretKey <- if (show_secret) pass else NA_character_
  
  api <- NA_character_
  path <- NA_character_
  
  res <- data.frame(row.names = NULL,
    status, alias, 
    accessKey, secretKey, token,
    URL, api, path
  )
  
  class(res) <- c("tbl_df", "tbl", "data.frame")
  res    
  
}

#' Returns all aliases known by the minio client, including those provided 
#' through MC_HOST_* environment variables
#' 
#' @param details logical to indicate whether results should be provided as
#' a vector with the alias names or as a data frame with full details
#' @param show_secret logical to indicate whether to display the secret pass
#' or to blank it out (the default)
#' @return a vector of aliases or a data frame with alias details
mc_aliases <- function(details = FALSE, show_secret = FALSE) {
  
  res <- read_jsonl(mc("alias ls --json", verbose = FALSE)$stdout)
  class(res) <- c("tbl_df", "tbl", "data.frame")
  env_res <- mc_alias_ls_env(details = details, show_secret = show_secret)
  
  if (!details) {
    return(unique(res$alias, env_res))
  }

  if (!show_secret) {
    res <- subset(res, select = -c("secretKey"))
    env_res <- subset(env_res, select = -c("secretKey"))
  }
  
  res$token <- NA_character_
  res <- rbind(res, env_res)
  res
}

starts_with_alias <- function(x) {
  re_aliases <- paste0("^", paste0(collapse = "|", mc_aliases()))
  grepl(re_aliases, x)
}

vreplace <- function(x, search = "", replace = NA_character_) {
  replace(x, x == search, replace)
}

#' @importFrom stats na.omit
parse_aws_env <- function() {
  
  # https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html
  env_keys <- c(
    "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY",
    "AWS_ENDPOINT_URL", "AWS_DEFAULT_REGION",
    "AWS_SESSION_TOKEN"
  )
  
  aws <- sapply(env_keys, Sys.getenv)
  missing_vars <- names(aws[aws == ""])
  
  message("The following AWS CLI system environment variables are not set:\n", 
          paste0(collapse = "\n", missing_vars))
  if ("AWS_ENDPOINT_URL" %in% missing_vars) {
    aws["AWS_ENDPOINT_URL"] <- "https://s3.amazonaws.com"
    message("Assumed AWS default for AWS_ENDPOINT_URL... ie ", aws["AWS_ENDPOINT_URL"])
  }
  
  use <- function(key) {
    res <- unname(aws[key])
    replace(res, res == "", NA_character_)
  }

  region <- use("AWS_DEFAULT_REGION")
  endpoint <- gs(use("AWS_ENDPOINT_URL"), "https*://", "")
  
  login <- use("AWS_ACCESS_KEY_ID")
  pass <- use("AWS_SECRET_ACCESS_KEY")
  token <- use("AWS_SESSION_TOKEN")
  triplet <- glue::glue_collapse(na.omit(c(login, pass, token)), sep = ":")

  use_https <- grepl("^https", use("AWS_ENDPOINT_URL"))
  proto <- sprintf("http%s://", if (use_https) "s" else "")
  
  as.character(glue::glue("{proto}{triplet}@{endpoint}"))
}

#' Creates and activates a MC_HOST_alias environment variable based on AWS 
#' system environment variables.
#' 
#' This function parses current system variable settings for  AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY,
#' AWS_DEFAULT_REGION, AWS_ENDPOINT_URL and AWS_SESSION_TOKEN and builds a
#' single MC_HOST_alias environment variable for the same connection and activates
#' this connection as an alias available to the minio client.
#' @param alias string with the alias name for the connection settings
set_alias_from_aws_env <- function(alias) {
  args <- list(parse_aws_env())
  names(args) <- sprintf("MC_HOST_%s", alias)
  do.call(Sys.setenv, args)  
}

unset_mc_host_env <- function(alias) {
  nme <- sprintf("MC_HOST_%s", alias)
  Sys.unsetenv(eval(quote(nme)))
}


