#' minio
#'
#' The MINIO server
#'
#' @param flags a character vector of flags to pass after the `minio server`
#'   command
#' @param dir the directories or directory specification where the minio server
#'   will store data. See the [server
#'   docs](https://min.io/docs/minio/linux/reference/minio-server/minio-server.html#minio.server.DIRECTORIES)
#'   for how to specify multiple directories.
#' @param process_args a list of additional arguments passed to
#'   [processx::process$run()][processx::process]. For instance, you can control
#'   most of the server configuration with by setting environment variables,
#'   e.e.g, `list(env = c("MINIO_ROOT_USER" = "user", "MINIO_ROOT_PASSWORD" =
#'   "password"))`.
#' @param path location where the minio  serverexecutable will be installed if
#'   not present. By default will use the OS-appropriate storage location.
#' @return Returns a [processx::process] handle to the running server.
#' @export
#' @details
#'
#' This function launches the minio server as a peristent process in teh
#' backgound. For documentation of options and flags available, see the server
#' documentation at
#' <https://min.io/docs/minio/linux/reference/minio-server/minio-server.html>.
#' @examplesIf interactive() 
#'   srv <- minio_server()
#'
#'   # The server health endpoint can be read by anyone and yields status 200
#'   curlGetHeaders("http://localhost:9000/minio/health/live")
#'   
#'   # But other info on the API requires authentication so yields a 403
#'   curlGetHeaders("http://localhost:9000/minio/v2/metrics/cluster")
#'   
#'   # Now visit the server at the URLs printed to the console
#'   # browseURL("http://localhost:9000/minio")
#'   srv$kill()
minio_server <- function(flags = c(), 
                  dir = tempdir(),
                  process_args = list(stdout = "", stderr = ""),
                  path = minio_server_path()) {
  
  binary <- fs::path(path, "minio")
  args <- c("server", flags, dir)
  
  
  
  if(!file.exists(binary) && interactive()) {
    proceed <- utils::askYesNo(
      "the minio server is not yet installed, should we install it now?")
    if(proceed) install_minio_server()
  }
  p <- do.call(processx::process$new, c
               (list(command = binary, args = args), process_args))
  

  
  p
}

