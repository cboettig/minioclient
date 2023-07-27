#' List files and directories using mc command
#'
#' This function uses the `mc` command to list files and directories
#'  at the specified target location.
#'
#' @param target character vector specifying the target directory path(s).
#' @param recursive Logical indicating whether to recursively list directories.
#'  Default is \code{FALSE}.
#' @param details logical, by default FALSE; if TRUE a data frame with details 
#' for the directory listing is returned.
#' @returns a vector of file or directory names ("keys" in minio parlance) or, 
#' if details is TRUE, a data.frame with the directory listing information
#'
#' @examplesIf interactive()
#' 
#' # list all buckets on play server
#' mc_ls("play/")
#' mc_ls("play", details = TRUE)
#'
#' @export
#' 
mc_ls <- function(target, recursive = FALSE, details = FALSE) {
  
  flags <- "--json"
  
  if (recursive) {
    flags <- paste("--recursive", flags)
  }
  
  stopifnot(length(target) >= 1)
  if (length(target) > 1) target <- paste0(collapse = " ", trimws(target))

  cmd <- paste("ls", flags, target)
  cmd <- gsub("\\s+", " ", cmd)

  out <- mc(cmd, verbose = FALSE)$stdout
  if (all(nchar(out) < 1)) return(data.frame())
  parse_mc_ls_jsonl(out, as_tbl = details, target = target)
  
}

# helper functions for parsing  
gs <- function(x, y, z) 
  gsub(pattern = y, replacement = z, x = x, perl = TRUE)

parse_json_ts <- function(x) {
  # exclude the colon in the timezone offset to enable using "%z" when parsing
  ts <- gs(x, "(.*?[+])(\\d{2}):(\\d{2})", "\\1\\2\\3")
  strptime(ts, format = "%Y-%m-%dT%H:%M:%OS%z")
}

format_json_sz <- function(x) {
  format_iec <- function(x) {
    class(x) <- "object_size"
    format(x, units = "auto", standard = "IEC")
  }
  sapply(x, format_iec)
}

read_jsonl <- function(x) {
  con <- textConnection(x)
  on.exit(close(con))
  jsonlite::stream_in(con, verbose = FALSE)
}

parse_alias <- function(x) {
  strsplit(x, "/+")[[1]][1]
}

parse_reldir <- function(x, target) {
  re_url <- "https*://(.*?)/+(.*)$"
  idx_url <- which(grepl(re_url, x))
  idx_local <- which(!grepl(re_url, x))
  res <- x
  res[idx_url] <- paste0(parse_alias(target), gs(x[idx_url], re_url, "/\\2"))
  res[idx_local] <- paste0(target, gs(x[idx_local], ".*?/+(.*?)$", "/\\2"))
  res
}

parse_mc_ls_jsonl <- function(x, as_tbl = FALSE, target) {
  
  df <- read_jsonl(x)
  
  if (!as_tbl) return(df$key)
  
  # convert to more specific types
  last_modified <- parse_json_ts(df$lastModified)
  size <- format_json_sz(df$size)
  #size <- fs::as_fs_bytes(df$size)
  is_folder <- df$type == "folder"

  # some columns are not provided when listing local files
  if (is.null(df$storageClass)) df$storageClass <- NA_character_
  if (all(df$etag == "")) df$etag <- NA_character_

  # remap some column names to simplify comparison with 
  # non-json stdout file listings
  
  key <- df$key
  bytes <- df$size
  storage_class <- df$storageClass
  ver <- df$versionOrdinal
  etag <- replace(df$etag, df$etag == "", NA_character_)
  dir <- df$url
  
  abspath <- paste0(dir, key)
  reldir <- NA
  relpath <- NA
  targets <- strsplit(target, " ")[[1]]
  if (length(targets) == 1) {
    reldir <- parse_reldir(dir, target)
    path <- paste0(reldir, key)
  }
  
  if (length(targets) > 1) 
    warning(paste0("Several target path specifications given... ",
      "targets could be a mix of local and remote paths... ", 
      "reldir and relpath will contain missing values."))
  
  res <- data.frame(
    key, last_modified, bytes, size, storage_class, is_folder, ver, etag, 
    dir, reldir, path, abspath
  )
  
  class(res) <- c("tbl_df", "tbl", "data.frame")
  res  
}
