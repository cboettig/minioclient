mc_stat <- function(targets, flags="", verbose = TRUE) {
  cmd <- paste("stat", flags, targets)
  cmd <- gsub("\\s+", " ", cmd)
  mc(cmd, verbose = verbose)
}

mc_stat_metadata <- function(target) {
  
  targets <- paste0(collapse = " ", trimws(target)) #trimws(strsplit(target, " ")[[1]])
  stat <- minioclient::mc(glue::glue("stat {targets} --json"), verbose = FALSE)$stdout 
#  stat <- mc_stat(targets, flags = "--json", verbose = FALSE)$stdout 
  
  con <- textConnection(stat)
  on.exit(close(con), add = TRUE)
  
  res <- jsonlite::stream_in(con, verbose = FALSE)
  res <- jsonlite::flatten(res)
  class(res) <- c("tbl_df", "tbl", "data.frame")
  res
}

target_type <- function(target) {
  
  if (is_alias(target)) 
    return("alias")
  
  res <- tryCatch(mc_stat_metadata(target), error = function(e) "invalid")
  
  if (length(res) == 1 && res == "invalid") 
    return (res)
  
  if (nrow(res) == 1 && c("type") %in% colnames(res) && res$type == "file") 
    return("object")
  
  if (nrow(res) > 1 && c("type") %in% colnames(res) && all(res$type == "folders")) 
    return("alias")
  
  if (nrow(res) == 1 & res$status == "success") 
    return("bucket")
  
  "unknown"
}

is_bucket <- function(target) {
  target_type(target) == "bucket"
}

is_alias <- function(target) {
  starts_with_alias(target) && length(strsplit(target, "/")[[1]]) == 1 && 
      gs(target, "/", "") %in% mc_aliases()
}
strip_trailing_slash <- function(x) gs(x, "(.*?)/+$", "\\1")

#' @importFrom stats setNames
read_metadata <- function(target, verbose = TRUE) {
  
  t <- strip_trailing_slash(target)
  type <- target_type(t)
  
  if (type == "invalid") stop("Not a valid target")

  md <- mc_stat_metadata(t)
  
  tilt <- function(x) {
    cn <- c("property", "value")
    df <- as.data.frame(t(x))
    df$property <- names(x)
    res <- setNames(df, rev(cn))
    class(res) <- c("tbl_df", "tbl", "data.frame")
    res <- res[,c(cn)]
    res$value <- replace(res$value, res$value == "", NA_character_)
    res
  }
  
  if (verbose) message("Metadata for ", t, " (", type, ")")
  
  switch(type, 
    "alias" = md,
    "bucket" = tilt(md),
    "object" = tilt(md),
    "folders" = md,
    NULL
  )
}

