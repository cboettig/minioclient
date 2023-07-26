#' List files and directories using mc command
#'
#' This function uses the `mc` command to list files and directories
#'  at the specified target location and returns a data frame with the results.
#'
#' @param target character vector specifying the target directory path(s).
#' @param recursive Logical indicating whether to recursively list directories.
#'  Default is \code{FALSE}.
#' @param show_fullpath logical, by default TRUE, a column with the 
#' full path is included in the listing
#' @returns a data.frame with the directory listing information
#'
#' @examplesIf interactive()
#' 
#' # list all buckets on play server
#' mc_ls("play/")
#'
#'
#' @export
#' 
mc_ls <- function(target, recursive = FALSE, show_fullpath = TRUE) {
  
  flags <- "--json"
  
  if (recursive) {
    flags <- paste("--recursive", flags)
  }
  
  stopifnot(length(target) >= 1)
  if (length(target) > 1) target <- paste0(collapse = " ", target)

  cmd <- paste("ls", flags, target)
  cmd <- gsub("\\s+", " ", cmd)

  out <- mc(cmd, verbose = FALSE)$stdout
  if (all(nchar(out) < 1)) return(data.frame())
  parse_mc_ls_jsonl(out, show_fullpath = show_fullpath)
  
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

parse_mc_ls_jsonl <- function(x, show_fullpath = TRUE) {
  
  con <- textConnection(x)
  on.exit(close(con))
  df <- jsonlite::stream_in(con, verbose = FALSE)
  
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
  dirpath <- df$url
  
  res <- data.frame(
    key, last_modified, bytes, size, storage_class, is_folder, ver, etag, dirpath
  )
  
  if (show_fullpath) res$fullpath <- paste0(res$dirpath, res$key)
  
  
  class(res) <- c("tbl_df", "tbl", "data.frame")
  res  
}
