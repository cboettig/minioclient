#' List files and directories using mc command
#'
#' This function uses the `mc` command to list files and directories
#'  at the specified target location.
#'
#' @param target Character string specifying the target directory path.
#' @param recursive Logical indicating whether to recursively list directories.
#'  Default is \code{FALSE}.
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
mc_ls <- function(target, recursive = FALSE, flags = "") {
  if (recursive) {
    flags <- paste("--recursive", flags)
  }
  cmd <- paste("ls", flags, target)
  cmd <- gsub("\\s+", " ", cmd)
  mc(cmd)
}

#' Directory listing as data frame
#'
#' This function parses the stdout from `mc_ls` and returns the result as a data frame.
#'
#' @param target Character string specifying the target directory path.
#' @param recursive Logical indicating whether to recursively list directories.
#'  Default is \code{FALSE}.
#' @returns a data.frame with the directory listing information
#' @export
mc_ls_tbl <- function(target, recursive = FALSE) {
  
  con <- textConnection(encoding = "UTF-8", object = suppressMessages(
    mc_ls(target=target, recursive=recursive)$stdout
  ))
  
  on.exit(close(con))
  
  out <- readLines(con)
  parse_mc_ls(trimws(out[nchar(out) > 0]))
  
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
  re_fn <- ".*?((.*?)\\s+)*(.*)$"

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

  # parse the rest of line, ie attribs, filename  
  rol <- gs(x, re_all, "\\6")
  filename <- gs(rol, re_fn, "\\3")
  attribs <- gs(rol, re_fn, "\\2")
  attribs[attribs == ""] <- NA
  
  # return a data frame
  res <- data.frame(stringsAsFactors = FALSE,
    timestamp, bytes, size, attribs, filename
  )
  
  class(res) <- c("tbl_df", "tbl", "data.frame")
  
  res

}
