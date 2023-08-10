is_df <- function(x)
    all(class(x) == c("tbl_df", "tbl", "data.frame")) &
    is.numeric(x$bytes) &
    nrow(x) > 0 &
    all(nchar(x$key) > 0) &
    "POSIXct" %in% class(x$last_modified)


test_that("mc_ls works for listing files at minio play server", {
  
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
  
  
  ls <- mc_ls("play/", details = TRUE)
  expect_true(is_df(ls))
})

test_that("mc_ls works for listing files locally", {
  
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc() 
  
  ls <- mc_ls(getwd(), details = TRUE)
  expect_true(is_df(ls))
})

test_that("mc_ls works for listing files recursively locally", {
  
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
  
  ls <- mc_ls(getwd(), details = TRUE, recursive = TRUE)
  
  expect_true(is_df(ls))
})

test_that("mc_ls provides path", {
  
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc() 
  
  ls <- mc_ls("play/", details = TRUE)
  has_path <- all(grepl("play", ls$path))
  
  expect_true(is_df(ls) & has_path)
})
