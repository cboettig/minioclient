test_that("s3 select api requests work and returns a data frame", {
  
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
  
  
  mc_mb("play/iris")
  tf <- tempfile(fileext = ".csv")
  write.csv(iris, row.names = FALSE, file = tf)
  mc_cp(tf, "play/iris/iris.csv")
  
  iris <- mc_sql("play/iris/iris.csv")
  
  is_valid <- nrow(iris) == 150 & ncol(iris) == 5
  
  expect_true(is_valid)
})

test_that("s3 select api requests work with a specific query used", {
  
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  
  install_mc()
  
  
  mc_mb("play/iris")
  tf <- tempfile(fileext = ".csv")
  write.csv(iris, row.names = FALSE, file = tf)
  mc_cp(tf, "play/iris/iris.csv")
  
  iris <- 
    mc_sql("play/iris/iris.csv", query = "select s.Species from S3Object s where s.Species = 'setosa' limit 6")
  
  is_valid <- nrow(iris) == 6
  
  expect_true(is_valid)
})
