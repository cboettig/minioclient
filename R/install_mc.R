

#' install the mc client or server
#' @param os operating system
#' @param arch architecture
#' @param path destination where binary is installed.
#' @param force install even if binary is already found. Can be used to force
#'   upgrade.
#' @return path to the minio client (mc) or server (minio) binary (invisibly)
#' @details This function is just a convenience wrapper for prebuilt MINIO
#'   binaries, from <https://dl.min.io/>. Should support Windows, Mac, and Linux
#'   on both Intel/AMD (amd64) and ARM architectures. For details, see official
#'   MINIO docs for your operating system, e.g.
#'   <https://min.io/docs/minio/macos/index.html>.
#'
#'   NOTE: If you want to install to other than the default location, simply set
#'   the options "minioclient.dir" or "minioserver.dir" to the appropriate
#'   location of the directory containing your "mc" or "minio" binary, e.g.
#'   `options("minioclient.dir" = "~/.mc")`. This is also used as the location
#'   of the config directory. Note that this package will not automatically use
#'   MINIO available on $PATH (to promote security and portability in design).
#' @examplesIf interactive() 
#'   install_mc()
#'   install_minio_server()
#'
#'   # Force upgrade 
#'   install_mc(force=TRUE)
#'   install_minio_server(force=TRUE)
#' @export
install_mc <- function(os = system_os(), arch = system_arch(),
                       path = minio_path(), force = FALSE ) {
  install_minio("client", os, arch, path, force)
}

#' @export
#' @rdname install_mc
install_minio_server <- function(os = system_os(), arch = system_arch(),
                                 path = minio_path(), force = FALSE ) {
  install_minio("server", os, arch, path, force)
}

install_minio <- function(what, os, arch, path, force) {
  os <- switch(os, 
               "mac" = "darwin",
               os)
  arch <- switch(arch, 
                 "x86_64" = "amd64",
                 "aarch64" = "arm64",
                 arch)
  
  bin_stub <- switch(what,
                     "client" = "mc",
                     "server" = "minio")
  bin <- switch(os,
                "windows" = paste0(bin_stub, ".exe"),
                bin_stub)
  
  type <- glue::glue("{os}-{arch}")
  
  binary <- fs::path(path, bin)
  if (file.exists(binary) && !force) {
    return(invisible(binary)) # Already installed
  }
  if (!file.exists(path)) {
    fs::dir_create(path)
  }
  
  utils::download.file(glue::glue("https://dl.min.io/{what}/{bin_stub}/release/",
                                  "{type}/{bin}"),
                       dest = binary, mode = "wb", quiet = TRUE)
  fs::file_chmod(binary, "+x")
  invisible(binary)
}

minio_path <- function() {
  getOption("minioclient.dir", 
            tools::R_user_dir("minioclient", "data")
  )
}

minio_server_path <- function() {
  getOption("minioserver.dir", 
            tools::R_user_dir("minioclient", "data")
  )
}
  

system_os <- function () {
  tolower(Sys.info()[["sysname"]])
}

system_arch <- function () {
  R.version$arch
}

