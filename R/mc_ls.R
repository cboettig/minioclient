#' List files and directories using mc command
#'
#' This function uses the `mc` command to list files and directories
#'  at the specified target location.
#'
#' @param target Character string specifying the target directory path.
#' @param recursive Logical indicating whether to recursively list directories.
#'  Default is \code{FALSE}.
#' @param verbose Logical indicating whether to display a message with stdout
#'  results from running the command
#' @param flags Additional flags to be passed to the `ls` command.
#'  Default is an empty string.
#' @inherit mc return
#'
#' @examplesIf interactive()
#' 
#' # list all buckets on play server
#' mc_ls("play/")
#'
#'
#' @export
mc_ls <- function(target, recursive = FALSE, flags = "", verbose = interactive()) {
  if (recursive) {
    flags <- paste("--recursive", flags)
  }
  cmd <- paste("ls", flags, target)
  cmd <- gsub("\\s+", " ", cmd)
  mc(cmd, verbose = verbose)
}

#' Directory listing as data frame
#'
#' This function parses the stdout from `mc_ls` and returns the result as a data frame.
#'
#' @param target Character string specifying the target directory path.
#' @param recursive Logical indicating whether to recursively list directories.
#'  Default is \code{FALSE}.
#' @param show_fullpath logical, by default FALSE, if TRUE, a column with the 
#' full path is included in the listing
#' @returns a data.frame with the directory listing information
#' @export
mc_ls_tbl <- function(target, recursive = FALSE, show_fullpath = FALSE) {
  
  out <- mc_ls(target = target, recursive = recursive, verbose = FALSE)$stdout
  if (nchar(out) < 1) return(data.frame())
  
  lines <- strsplit(out, "\n")[[1]]
  res <- parse_mc_ls(lines)
  
  if (show_fullpath) {
    # strip and reattach slash if fullpath is requested
    fp <- file.path(gsub("(.*?)/+$", "\\1", target), res$filename)
    res$fullpath <- fp
  }
  
  res
}

# helper functions for parsing  
gs <- function(x, y, z) 
  gsub(pattern = y, replacement = z, x = x, perl = TRUE)

strpsize <- function(x) {
  digits <- as.double(gsub("[^0-9.]", "", x))
  units <- trimws(gsub("[0-9.]", "", x))
  # inspired by utils:::format.object_size
  units_IEC <- c("B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB")
  multipliers <- unname(sapply(units, function(x) 1024 ^(which(x == units_IEC) - 1)))
  digits * multipliers
}

parse_dttm <- function(x, tz, format = "%Y-%m-%d %H:%M:%S") {
  
  strpdate <- function(x, zone, fmt = format)
    strptime(x, format = fmt, tz = zone)
  
  vstrpdate <- Vectorize(strpdate)
  
  Reduce(c, vstrpdate(x, zone = tz))
}

parse_mc_ls <- function(x, ts_format = "%Y-%m-%d %H:%M:%S") {

  # regular expressions for extracting components from mc_ls stdout
  re_time <- "\\[(.*?)\\s+(.*?)\\s+(.*?)\\].*$"
  re_size <- ".*?\\]\\s+(\\d+\\.*\\d*)(.*?B).*$"
  re_all <- "\\[(.*?)\\s+(.*?)\\s+(.*?)\\]\\s+(\\d+\\.*\\d*)(.*B)\\s+(.*)$"
  
  # after time and size, the rest of the line contains "storage class" info (optionally) and filename
  # https://github.com/minio/mc/blob/1c17ff4c995d772c97eed8c5a269f2074a9425fe/cmd/ilm-tier-add.go#L149-L152
  re_rol <- ".*?((STANDARD|REDUCED_REDUNDANCY)\\s+)*(.*)$"
  re_trailing_slash <- ".*?/$"

  # parse time components
  dt <- gs(x, re_time, "\\1")
  ts <- gs(x, re_time, "\\2")
  tz <- gs(x, re_time, "\\3")
  timestamp <- parse_dttm(paste(dt, ts), tz, format = ts_format)

  # parse size components  
  sz <- as.double(gs(x, re_size, "\\1"))
  sz_unit <- gs(x, re_size, "\\2")
  size <- paste(sz, sz_unit)
  bytes <- strpsize(paste(sz, sz_unit))

  # parse the rest of line, ie storage class and filename  
  rol <- gs(x, re_all, "\\6")
  filename <- gs(rol, re_rol, "\\3")
  storage_class <- gs(rol, re_rol, "\\2")
  storage_class[storage_class == ""] <- NA
  is_folder <- grepl(re_trailing_slash, filename)
  
  # return a data frame
  res <- data.frame(stringsAsFactors = FALSE,
    timestamp, bytes, size, storage_class, filename, is_folder
  )
  
  class(res) <- c("tbl_df", "tbl", "data.frame")
  
  res

}
