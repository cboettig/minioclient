

#' install the mc client
#' @param os operating system
#' @param arch architecture
#' @param path destination where binary is installed.
#' @param force install even if binary is already found.
#'  Can be used to force upgrade.
#' @param verbose logical to indicate whether to display verbose messages from
#' the download process, by default FALSE
#' @return path to the minio binary (invisibly)
#' @details This function is just a convenience wrapper for prebuilt MINIO
#' binaries, from <https://dl.min.io/client/mc/release/>. Should
#' support Windows, Mac, and Linux on both Intel/AMD (amd64) and ARM
#' architectures.
#' For details, see official MINIO docs for your operating system,
#' e.g. <https://min.io/docs/minio/macos/index.html>. 
#' 
#' NOTE: If you want to install to other than the default location, 
#' simply set the option "minioclient.dir", to the appropriate location of the 
#' directory containing your "mc" binary, e.g.
#'  `options("minioclient.dir" = "~/.mc")`. This is also used as the location
#'  of the config directory. Note that this package
#'  will not automatically use MINIO available on $PATH (to promote security
#'  and portability in design). 
#' @examplesIf interactive()
#' install_mc()
#' 
#' # Force upgrade
#' install_mc(force=TRUE)
#' 
#' @export
install_mc <- function(os = system_os(), arch = system_arch(),
                       path = minio_path(), force = FALSE, verbose = FALSE) {
  
  os <- switch(os, 
               "mac" = "darwin",
               os)
  arch <- switch(arch, 
                 "x86_64" = "amd64",
                 "aarch64" = "arm64",
                 arch)
  bin <- switch(os,
                "windows" = "mc.exe",
                "mc")
  type <- glue::glue("{os}-{arch}")
  
  binary <- fs::path(path, bin)
  if (file.exists(binary) && !force) {
    return(invisible(binary)) # Already installed
  }
  
  # to avoid special case, see 
  # https://stackoverflow.com/questions/16764946/what-generates-the-text-file-busy-message-in-unix
  if (file.exists(binary) && force) {
    unlink(binary)
  }
  
  if (!file.exists(path)) {
    fs::dir_create(path)
  }
  
  org_timeout <- getOption("timeout")
  options(timeout = max(600, getOption("timeout")))
  on.exit(options(timeout = org_timeout), add = TRUE)
  
  if (verbose) {
    message(paste0("Due to download rate limiting at dl.min.io, the download ",
    "for the 25 Mb mc binary can be slow, around 10 minutes."))
    org_ii <- getOption("internet.info")
    options(`internet.info` = 1)
    on.exit(options(`internet.info` = org_ii), add = TRUE)
  }
  
  utils::download.file(glue::glue("https://dl.min.io/client/mc/release/",
                                  "{type}/{bin}"),
                       dest = binary, mode = "wb", quiet = !verbose, 
                       method = "libcurl")
  fs::file_chmod(binary, "+x")
  invisible(binary)
}

minio_path <- function() {
  getOption("minioclient.dir", 
            tools::R_user_dir("minioclient", "data")
  )
}

system_os <- function () {
  tolower(Sys.info()[["sysname"]])
}

system_arch <- function () {
  R.version$arch
}

