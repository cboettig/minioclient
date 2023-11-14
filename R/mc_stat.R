#' Show object metadata
#' 
#' Object metadata can include information about content type and
#' various other metadata attributes, if associated with the object.
#' 
#' @param target the target specification, for example "play" (an alias) or 
#' "s3/openalex" (a bucket) or "play/test/test.tar.gz" (a specific object) or "R" 
#' (a local path)
#' @param verbose logical indicating whether to include some additional information, 
#' by default TRUE
#' @param flags string with additional flags to be sent along to minio client, 
#' such as "--recursive"
#' @param details logical for returning results as a data frame, by default FALSE
mc_stat <- function(target, verbose = TRUE, flags = "", details = FALSE) {
  if (details) {
    read_metadata(target, verbose = verbose)
  } else {
    mc_stat_original(targets = target, flags = flags, verbose = verbose)
  }
} 

mc_stat_original <- function(targets, flags="", verbose = TRUE) {
  
  if (length(targets) > 1) 
    targets <- paste0(collapse = " ", trimws(targets))
  
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
  
  if (nrow(res) == 1 && res$status == "success") 
    return("bucket")
  
  if (nrow(res) > 0 && "metadata.X-Amz-Meta-Mc-Attrs" %in% colnames(res) &&
    all(grepl("^atime", getElement(res, "metadata.X-Amz-Meta-Mc-Attrs"))))
      return("local")
  
  "unknown"
}

is_bucket <- function(target) {
  target_type(target) == "bucket"
}

is_alias <- function(target) {
  all(starts_with_alias(target)) && 
  1 %in% sapply(strsplit(target, "/"), length) && 
  all(gs(target, "/", "") %in% mc_alias_ls())
}

strip_trailing_slash <- function(x) 
  gs(x, "(.*?)/+$", "\\1")

#' @importFrom stats setNames
read_metadata <- function(target, verbose = TRUE) {
  
  t <- strip_trailing_slash(target)
  type <- target_type(t)
  
  if (type == "invalid") stop("Not a valid target")
  if (type == "local") t <- target

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
  
  if (verbose) 
    message("Metadata for ", paste(collapse = " ", t), 
      " (", paste(collapse = " ", type), ")")
  
  switch(type, 
    "alias" = md,
    "bucket" = tilt(md),
    "object" = tilt(md),
    "folders" = md,
    "local" = md,
    stop("The type of the specified target could not be determined.")
  )
}

