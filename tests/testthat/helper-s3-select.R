# The public play.min.io sandbox (and recent MinIO releases generally) no
# longer expose the S3 Select API, so mc_sql() requests come back as a
# "MethodNotAllowed" server error. Treat that specific case as a skip while
# still letting other, unexpected failures fail the test.
s3_select_unsupported <- function(e) {
  grepl("not allowed|methodnotallowed|not enabled|s3 select",
        conditionMessage(e), ignore.case = TRUE)
}

skip_if_s3_select_unsupported <- function(e) {
  if (s3_select_unsupported(e)) {
    skip(paste("S3 Select not supported by server:", conditionMessage(e)))
  }
  stop(e)
}
