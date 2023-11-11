test_that("server install works", {
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_minio_server()
  expect_true(TRUE)
})

test_that("server launch works", {
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_minio_server()
  
  srv <- minio_server(process_args = list())
  on.exit(srv$kill())
  Sys.sleep(3)
  
  expect_true(srv$is_alive())
  
  expect_equal(
    attr(curlGetHeaders("http://localhost:9000/minio/health/live"), "status"),
    200)
  
  expect_equal(
    attr(curlGetHeaders("http://localhost:9000/minio/v2/metrics/cluster"), "status"),
    403)
  
  x <- mc_alias_set("myserver", "localhost:9000", "minioadmin", "minioadmin", scheme = "http")
  x <- mc_mb("myserver/bucket1")
  
  tf <- tempfile()
  write.csv(faithful, tf, row.names = FALSE)
  on.exit(unlink(tf))
  
  x <- mc_cp(tf, "myserver/bucket1/faithful.csv")
  
  files <- mc_ls("myserver/bucket1")
  expect_equal(files, "faithful.csv")
  
  expect_equal(
    read.csv(textConnection(mc_cat("myserver/bucket1/faithful.csv")), colClasses = c("numeric", "numeric")),
    faithful
  )
  
  
})
