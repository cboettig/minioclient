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
#' @export 
#' @details 
#' 
#' See <https://min.io/docs/minio/linux/reference/minio-mc/mc-sql.html#> and 
#' <https://github.com/minio/minio/blob/master/docs/select/README.md>
#' 
#' For example "select s.* from S3Object limit 10" is valid syntax.
#' 
#' More examples of query syntax here: 
#' <https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-select-sql-reference-select.html>
mc_sql <- function(target, query = "select * from S3Object", recursive = TRUE, verbose = FALSE) {
  
  binary <- fs::path(bin_path(), "mc")
  
  if(!file.exists(binary)) {
    install_mc()
  }
  
  args <- c("sql", "--json", ifelse(recursive, "--recursive", NULL), 
            "--query", query, target)
  
  p <- processx::run(binary, args)
  
  if (p$timeout & verbose) warning(paste("request for mc sql query timed out"))
  if (p$status != 0) stop(paste(p$stderr))
  
  if (verbose) message(paste0(p$stdout))
  
  con <- textConnection(p$stdout)
  on.exit(close(con))
  res <- jsonlite::stream_in(con, verbose = FALSE)
  class(res) <- c("tbl_df", "tbl", "data.frame")
  res  
}
