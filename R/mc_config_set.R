#' mc_config_set
#' 
#' Edit the config files, e.g. to add a sessionToken
#' @param alias A configured alias, see [mc_alias_set()]
#' @param key the parameter name, e.g. `sessionToken`
#' @param value the value to set the parameter to
#' @param json path to the config
#' @return updates configuration and returns silently (`NULL`). 
#' @examplesIf interactive()
#' 
#' mc_config_set("play", key="sessionToken", value="MyTmpSessionToken")
#' 
#' @export
mc_config_set <- function(alias,
                          key, 
                          value,
                          json = file.path(minio_path(), "config.json")) {
  config <- jsonlite::read_json(json)
  
  config[["aliases"]][[alias]][[key]] <- value
  jsonlite::write_json(config, json)
  
}