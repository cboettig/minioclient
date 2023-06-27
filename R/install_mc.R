

#' install the mc client
#' @param os operating system
#' @param arch architecture
#' @param path destination where binary is installed.
#' @param force install even if binary is already found.
#'  Can be used to force upgrade.
#' @return path to the minio binary (invisibly)
#' @details This function is just a convenience wrapper for prebuilt MINIO
#' binaries, from <https://dl.min.io/client/mc/release/>. Should
#' support Windows, Mac, and Linux on both Intel/AMD (amd64) and ARM
#' architectures.
#' For details, see official MINIO docs for your operating system,
#' e.g. <https://min.io/docs/minio/macos/index.html>. 
#' 
#' NOTE: If you want to install to other than the default location, OR if you
#' already have a minio client installed somewhere and want to use that, 
#' simply set the option "mc.bin.dir", to the appropriate location of the 
#' directory containing your "mc" binary, e.g.
#'  `options("mc.bin.dir" = "/usr/local/bin)`.  Note that this package
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
                       path = bin_path(), force = FALSE ) {
  
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
  if (!file.exists(path)) {
    fs::dir_create(path)
  }
  
  utils::download.file(glue::glue("https://dl.min.io/client/mc/release/",
                                  "{type}/{bin}"),
                       dest = binary, mode = "wb", quiet = TRUE)
  fs::file_chmod(binary, "+x")
  invisible(binary)
}

bin_path <- function() {
  getOption("mc.bin.dir", 
            tools::R_user_dir("mc", "data")
  )
}

system_os <- function () {
  tolower(Sys.info()[["sysname"]])
}

system_arch <- function () {
  R.version$arch
}

