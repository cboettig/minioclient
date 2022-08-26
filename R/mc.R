
#' @export
mc <- function(command, ..., path = bin_path()) {
  binary <- fs::path(path, "mc")
  system2(binary, command)
  
  #cmd <- paste(binary, command)
  #processx::run(cmd)
  
}

mc_ls <- function(command, ..., path = bin_path()) {
  mc(paste("ls", command), ..., path = path)
}



#' install the mc client
#' @param os operating system
#' @param arch architecture ("amd64" or "ppc64")
#' @param path destination where binary is installed.
#' @export
install_mc <- function(os = "linux", arch = "amd64", path = bin_path() ) {

  # FIXME linux-amd64 only so far:
  
  binary <- fs::path(path, "mc")
  if(!file.exists(path)) fs::dir_create(path)
  download.file(glue::glue("https://dl.min.io/client/mc/release/",
                           "linux-{arch}/mc"),
                dest = binary, mode = "wb")
  fs::file_chmod(binary, "+x")
  binary
}

bin_path <- function() {
  getOption("mc.bin.dir", 
            tools::R_user_dir("mc", "data")
  )
}


