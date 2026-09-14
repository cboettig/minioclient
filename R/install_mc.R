# The last release published to the open-source 'minio/mc' repository.
#
# MinIO moved the client into its closed-source AIStor product: the community
# download host was retired (every https://dl.min.io/client/mc/release/ URL
# now answers "410 Gone") and the 'minio/mc' repository was archived. The
# binaries attached to that final tag are still served from GitHub, so this
# package pins them. That means `install_mc()` installs a frozen, legacy
# client: it is not tracking upstream and will not gain new features.
mc_release <- "RELEASE.2025-08-13T08-35-41Z"

#' install the mc client
#' @param os operating system
#' @param arch architecture
#' @param path destination where binary is installed.
#' @param force install even if binary is already found.
#'  Can be used to force upgrade.
#' @param version release tag of the 'mc' client to install. Defaults to the
#'  last release published under the open-source 'minio/mc' repository.
#' @return path to the minio binary (invisibly)
#' @details This function is just a convenience wrapper for prebuilt MINIO
#' binaries. MinIO has since moved the client to its closed-source AIStor
#' product: the former download host, <https://dl.min.io/client/mc/release/>,
#' now returns "410 Gone", and the <https://github.com/minio/mc> repository has
#' been archived. This package therefore installs the last release published
#' there, from its GitHub release assets, so that existing workflows keep
#' working. The client is frozen at that version and will receive no further
#' upstream fixes. Should support Windows, Mac, and Linux on both Intel/AMD
#' (amd64) and ARM architectures.
#'
#' NOTE: If you want to install to other than the default location,
#' simply set the option "minioclient.dir", to the appropriate location of the
#' directory containing your "mc" binary, e.g.
#'  `options("minioclient.dir" = "~/.mc")`. This is also used as the location
#'  of the config directory. Note that this package
#'  will not automatically use MINIO available on $PATH (to promote security
#'  and portability in design).
#'
#' Two further options cover the case where the pinned release is no longer
#' reachable: set `options("minioclient.version")` to install a different
#' release tag, or `options("minioclient.url")` to give the full URL of an
#' `mc` binary to download (e.g. an internal mirror).
#' @examplesIf interactive()
#' install_mc()
#' 
#' # Force upgrade
#' install_mc(force=TRUE)
#' 
#' @export
install_mc <- function(os = system_os(), arch = system_arch(),
                       path = minio_path(), force = FALSE,
                       version = mc_version()) {

  os <- mc_os(os)
  bin <- mc_bin(os)

  binary <- fs::path(path, bin)
  if (file.exists(binary) && !force) {
    return(invisible(binary)) # Already installed
  }
  if (!file.exists(path)) {
    fs::dir_create(path)
  }

  url <- mc_url(os, arch, version)

  # Download beside the destination (same filesystem, so the rename below is
  # atomic) rather than onto it: a failed or truncated download must not leave
  # something behind that later looks like an installed client.
  tmp <- fs::path(path, paste0(bin, ".download"))
  on.exit(unlink(tmp), add = TRUE)

  ok <- tryCatch(
    identical(as.integer(
      utils::download.file(url, destfile = tmp, mode = "wb", quiet = TRUE)
    ), 0L),
    error = function(e) FALSE,
    warning = function(w) FALSE
  )
  # An error page served with a 200 would pass the status check; the client is
  # tens of MB, so anything tiny is not the binary we asked for.
  if (!ok || !file.exists(tmp) || file.size(tmp) < 1e6) {
    stop(mc_download_error(url, version), call. = FALSE)
  }

  fs::file_move(tmp, binary)
  fs::file_chmod(binary, "+x")
  invisible(binary)
}

mc_download_error <- function(url, version) {
  glue::glue(
    "Failed to download the 'mc' client from:\n  {url}\n\n",
    "MinIO has discontinued the open-source client: the official download ",
    "host (dl.min.io) now returns '410 Gone' and the 'minio/mc' repository ",
    "has been archived. This package installs the last release published ",
    "there ({version}). If that asset is unavailable too, either install ",
    "'mc' yourself and point the package at it with\n",
    '  options(minioclient.dir = "<directory containing mc>")\n',
    "or supply a mirror with\n",
    '  options(minioclient.url = "<url of an mc binary>")'
  )
}

# Release tag to install, overridable for users who need a different one.
mc_version <- function() {
  getOption("minioclient.version", mc_release)
}

# Where to fetch the binary. The GitHub release assets are named
# mc.<os>-<arch>.<tag>, e.g. mc.linux-amd64.RELEASE.2025-08-13T08-35-41Z --
# except the Windows asset, which carries a trailing ".exe".
mc_url <- function(os = system_os(), arch = system_arch(),
                   version = mc_version()) {
  mirror <- getOption("minioclient.url", NULL)
  if (!is.null(mirror)) {
    return(mirror)
  }
  os <- mc_os(os)
  arch <- mc_arch(arch)
  ext <- if (identical(os, "windows")) ".exe" else ""
  as.character(
    glue::glue("https://github.com/minio/mc/releases/download/{version}/",
               "mc.{os}-{arch}.{version}{ext}")
  )
}

# Translate R's names for the platform into the ones upstream builds under.
mc_os <- function(os = system_os()) {
  switch(os,
         "mac" = "darwin",
         os)
}

mc_arch <- function(arch = system_arch()) {
  switch(arch,
         "x86_64" = "amd64",
         "aarch64" = "arm64",
         arch)
}

minio_path <- function() {
  getOption("minioclient.dir", 
            tools::R_user_dir("minioclient", "data")
  )
}

system_os <- function () {
  tolower(Sys.info()[["sysname"]])
}

# Name of the mc binary on the current OS. Windows ships as "mc.exe";
# all others use "mc". Used by both install_mc() (where to write the
# binary) and mc() (where to look for it) so the two never disagree.
mc_bin <- function (os = system_os()) {
  switch(os,
         "windows" = "mc.exe",
         "mc")
}

system_arch <- function () {
  R.version$arch
}
