
#' mc alias set
#' 
#' Set a new alias for the minio client, possibly using env var defaults.
#' @param alias a short name for this endpoint
#' @param endpoint_url the endpoint url, starting with the scheme, for example
#'   "http://localhost:9000" or "https://play.min.io" or "https://s3.amazonaws.com"
#' @param access_key access key (user)
#' @param secret_key secret access key
#' @param token temporary session token
#' @param storage one of "config" (default) or "env", to indicate if the alias setting 
#' should be stored in the config file for the minio client or as a system
#' environment variable
#' @param use_aws_env logical to indicate whether settings for the alias should
#' be inferred from currently specified AWS environment variables
#' @inherit mc return
#' @references <https://min.io/docs/minio/linux/reference/minio-mc.html>.
#' Note that keys can be omitted for anonymous use.
#' 
#' @examplesIf interactive()
#' 
#' mc_alias_set()
#' 
#' @export
mc_alias_set <- function(alias, endpoint_url, 
  access_key = NA, secret_key = NA, token = NA, 
  storage = c("config", "env"),
  use_aws_env = FALSE) {
  
  if (use_aws_env) {
    setting <- parse_aws_env(alias)
  } else {
    setting <- mc_host_env(alias = alias, endpoint_url = endpoint_url, 
      login = access_key, pass = secret_key, token = token
    )
  }
  
  switch(match.arg(storage), 
    "config" = {
      params <- parse_mc_host_env(setting, show_secret = T)
      if (!nzchar(params$URL))
        stop("Please provide an endpoint_url setting")
      if (!nzchar(params$alias))
        stop("Please provide a setting for the alias name")
      cmd <- glue::glue("alias set {params$alias} {params$URL}")
      if (!nzchar(params$secretKey))
        cmd <- glue::glue(cmd, " {params$accessKey} {params$secretKey}")
      mc(cmd)
      # append session token (see https://github.com/minio/mc/issues/2444)
      if (!missing(token)) {
        mc_config_set(alias = alias, key = "sessionToken", value = params$token)
      }
    },
    "env" = {
      do.call(Sys.setenv, setting)
    }
  )
}

mc_alias_ls_env <- function(alias, details = FALSE, show_secret = FALSE) {
  envs <- Sys.getenv()[which(grepl("^MC_HOST_.*", names(Sys.getenv())))]
  aliases <- gs(names(envs), "MC_HOST_", "")
  if (!missing(alias)) {
    i <- aliases %in% alias
    aliases <- aliases[i]
    envs <- envs[i]
  }
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
#' settings required for making a connection an S3 server. 
#' 
#' @param x a named vector - where the name corresponds to the "alias"
#' @param show_secret logical indicating whether to blank out or
#' to include the secret access key (the default)
#' @return a data frame with the same columns as when 
parse_mc_host_env <- function(x, show_secret = TRUE) {
  
  if (length(x) == 0) return(data.frame())
   
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

  re_skeleton <- "(https?://(.*))?@(.*?)$"
  
  endpoint <- gsr(gsr(x, re_skeleton, "\\3"), "https?://", "")  
  triplet <- ifelse(grepl("@", x), gsr(x, re_skeleton, "\\2"), "")
  
  # now parse the components
  
  alias <- gsr(names(x), "MC_HOST_", "")
  
  trip <- lapply(strsplit(triplet, split = ":"), "[", 1:3)
  login <- vreplace(sapply(trip, "[", 1))
  pass <- vreplace(sapply(trip, "[", 2))
  token <- vreplace(sapply(trip, "[", 3))

  # server info
  proto <- gsr(x, ".*?(https?)://.*$", "\\1")

  hp <- lapply(strsplit(endpoint, c(":")), "[", 1:2)
  host <- vreplace(sapply(hp, "[", 1))
  port <- vreplace(sapply(hp, "[", 2))

  URL <- paste0(proto, "://", host, 
    ifelse(is.na(port), "", paste0(":", port)))
  
  # TODO: better regexp for validating MC_HOST_*-urls
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
#' @param alias single string with the alias to filter for, by default missing
#' @param details logical to indicate whether results should be provided as
#' a vector with the alias names or as a data frame with full details
#' @param include_all logical to indicate whether to include also temporary aliases
#' specified through MC_HOST_* environment variable settings
#' @param show_secret logical to indicate whether to display the secret pass
#' or to blank it out (the default)
#' @return a vector of aliases or a data frame with alias details
mc_alias_ls <- function(alias, details = FALSE, include_all = TRUE, show_secret = FALSE) {
  
  if (!missing(alias) && length(alias) > 1)
    stop("The mc alias list command allows only one argument")

  include_conf <- TRUE
  
  if (include_all) {
    aliases_env <- mc_alias_ls_env(alias = alias, 
       details = details, show_secret = show_secret)
    class(aliases_env) <- c("tbl_df", "tbl", "data.frame")
    # do not look up aliases from the conf which is resolved from env
    if (!missing(alias) && details && (nrow(aliases_env) > 0)) {
      alias <- alias[!(aliases_env$alias %in% alias)]
    } else if (!missing(alias) && !details && (length(aliases_env) > 0)) {
      alias <- alias[!(aliases_env %in% alias)]
    }
  }
  
  alias_args <- ""
  
  if (!missing(alias) && length(alias) == 0)  # no aliases left to lookup in conf...
        include_conf <- FALSE  
  
  if (!missing(alias)) 
    alias_args <- paste0(collapse = " ", trimws(alias))

  if (include_conf) {
    mc_response <- #tryCatch(
      mc(glue::glue("alias ls --json {alias_args}"), verbose = FALSE)$stdout#,
    #  error = function(e) ""
    #)
    aliases_conf <- read_jsonl(mc_response)
    class(aliases_conf) <- c("tbl_df", "tbl", "data.frame")
  } else {
    aliases_conf <- data.frame()
    class(aliases_conf) <- c("tbl_df", "tbl", "data.frame")
  }

  # token can not be specified in .mc/config.json (yet?)
  if (nrow(aliases_conf) > 0) 
    aliases_conf$token <- NA_character_
  
  if (!include_all) {
    if (!details) return(unique(aliases_conf$alias))
    if (!show_secret) {
      if (nrow(aliases_conf) > 0) aliases_conf$secretKey <- NA_character_
    }
    return(aliases_conf)
  }
  
  # include MC_HOST_* settings
  # TODO: do this first, since these take precedence over the config file
  # TODO: double check the go-code to verify that this is the case
  # TODO: then exclude any "aliases" found that are MC_HOST_* alias
  # from the query to "mc alias ls"
  # OOPS: this command does not allow multiple arguments ie not vectorized...
  
  if (!details) {
    aliases <- unique(c(if (nrow(aliases_conf) > 0) aliases_conf$alias else NULL, aliases_env))
    return(aliases)
  } else {
    if (include_conf) {
      aliases <- rbind.data.frame(aliases_conf, aliases_env)
    } else {
      aliases <- aliases_env
    }
    if (!show_secret) aliases$secretKey <- NA_character_
    class(aliases) <- c("tbl_df", "tbl", "data.frame")
    return(aliases)
  }
  
}

starts_with_alias <- function(x) {
  re_aliases <- paste0("^", paste0(collapse = "|", mc_alias_ls()))
  grepl(re_aliases, x)
}

vreplace <- function(x, search = "", replace = NA_character_) {
  replace(x, x == search, replace)
}

#' @importFrom stats na.omit
parse_aws_env <- function(alias) {
  
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
  endpoint_url <- use("AWS_ENDPOINT_URL")
  login <- use("AWS_ACCESS_KEY_ID")
  pass <- use("AWS_SECRET_ACCESS_KEY")
  token <- use("AWS_SESSION_TOKEN")
  
  if (missing(alias)) alias <- "aws"
  
  mc_host_env(alias, endpoint_url, login, pass, token)
#  triplet <- glue::glue_collapse(na.omit(c(login, pass, token)), sep = ":")

#  use_https <- grepl("^https", use("AWS_ENDPOINT_URL"))
#  proto <- sprintf("http%s://", if (use_https) "s" else "")
  
#  as.character(glue::glue("{proto}{triplet}@{endpoint}"))
}

mc_host_env <- function(alias, endpoint_url, login = NA, pass = NA, token = NA) {

  use_https <- grepl("^https", endpoint_url)
  proto <- sprintf("http%s://", if (use_https) "s" else "")
  endpoint <- gs(endpoint_url, "https?://", "")
  
  triplet <- as.character(glue::glue_collapse(na.omit(c(login, pass, token)), sep = ":"))
  
  if (length(triplet) == 0) {
    message("No login/pass/token for alias ", alias)
    triplet <- NULL
    val <- as.character(glue::glue("{proto}{endpoint}", .na = "", .null = ""))
  }
  
  alias <- paste0("MC_HOST_", alias)
  if (!is.null(triplet))
    val <- as.character(glue::glue("{proto}{triplet}@{endpoint}", .na = "", .null = ""))
  names(val) <- alias
  as.list(val)
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
  #args <- list(parse_aws_env(alias = alias))
  #names(args) <- sprintf("MC_HOST_%s", alias)
  if (missing(alias)) message("Will use alias \"aws\" by default.")
  args <- as.list(parse_aws_env(alias = alias))
  do.call(Sys.setenv, args)
}

unset_mc_host_env <- function(alias) {
  nme <- sprintf("MC_HOST_%s", alias)
  Sys.unsetenv(eval(quote(nme)))
}


