#' Use the S3 variant of SQL to query a minio object
#' 
#' The S3 Select API can be used against CSV and JSON objects stored in minio. 
#' If the minio server runs with MINIO_API_SELECT_PARQUET=on, also parquet files 
#' can be queried.
#' 
#' @param target character alias or path specification at minio for 
#' the object (a .csv, .json or .parquet file)
#' @param query character string with sql query, by default "select * from S3Object"
#' @param recursive logical, by default TRUE, allowing a s3 select query to work 
#' across a minio ALIAS/PATH specification
#' @param verbose logical, by default FALSE
#' @return SQL query results as a `data.frame` of class `tbl_df`
#' @export 
#' @details 
#' 
#' See <https://min.io/docs/minio/linux/reference/minio-mc/mc-sql.html#> and 
#' <https://github.com/minio/minio/blob/master/docs/select/README.md>
#' 
#' For example "select s.* from S3Object s limit 10" is valid syntax.
#' 
#' More examples of query syntax here: 
#' <https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-select-sql-reference-select.html>
#' @examplesIf interactive()
#' install_mc()
#' # upload a CSV file
#' tf <- tempfile()
#' write.csv(iris, tf, row.names = FALSE)
#' mc_mb("play/iris")
#' mc_cp(tf, "play/iris/iris.csv")
#' 
#' # read first 12 lines from the CSV
#' mc_sql("play/iris/iris.csv", query = "select * from S3Object limit 12")
#'  
mc_sql <- function(target,
                   query = "select * from S3Object",
                   recursive = TRUE, 
                   verbose = FALSE) {
  
  binary <- fs::path(minio_path(), mc_bin())
  
  if(!file.exists(binary)) {
    install_mc()
  }
  
  args <- c("sql", "--json", ifelse(recursive, "--recursive", NULL), 
            "--query", query, target)
  
  # error_on_status = FALSE so the status check below can surface mc's own
  # stderr; otherwise processx throws first and the server's message (e.g.
  # "method is not allowed" from a server without S3 Select) is buried in a
  # generic "System command 'mc' failed".
  p <- processx::run(binary, args, error_on_status = FALSE)
  
  if (p$timeout & verbose) warning(paste("request for mc sql query timed out"))
  if (p$status != 0) stop(paste(p$stderr))
  
  if (verbose) message(paste0(p$stdout))
  
  con <- textConnection(p$stdout)
  on.exit(close(con))
  res <- jsonlite::stream_in(con, verbose = FALSE)

  # With --json, mc reports S3-Select server errors as a JSON object on
  # stdout while still exiting 0 (e.g. servers that do not support the S3
  # Select API). Surface these as R errors rather than returning the error
  # payload as if it were query results.
  if ("status" %in% names(res) && any(res$status == "error", na.rm = TRUE)) {
    stop(paste("mc sql request failed:", p$stdout), call. = FALSE)
  }

  class(res) <- c("tbl_df", "tbl", "data.frame")
  res
}
