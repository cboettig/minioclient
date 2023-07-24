is_df <- function(x)
    all(class(x) == c("tbl_df", "tbl", "data.frame")) &
    is.numeric(x$bytes) &
    nrow(x) > 0 &
    all(nchar(x$filename) > 0) &
    "POSIXct" %in% class(x$timestamp)


test_that("mc_ls_tbl works for listing files at minio play server", {
  
  skip_on_cran()
  skip_if_offline()  
  
  ls <- mc_ls_tbl("play/")
  expect_true(is_df(ls))
})

test_that("mc_ls_tbl works for listing files locally", {
  
  skip_on_cran()
  skip_if_offline()  
  
  ls <- mc_ls_tbl(getwd())
  expect_true(is_df(ls))
})

test_that("mc_ls_tbl works for listing files recursively locally", {
  
  skip_on_cran()
  skip_if_offline()  
  
  ls <- mc_ls_tbl(getwd(), recursive = TRUE)
  
  expect_true(is_df(ls))
})

test_that("mc_ls_tbl can provide fullpath", {
  
  skip_on_cran()
  skip_if_offline()  
  
  ls <- mc_ls_tbl("play/", show_fullpath = TRUE)
  has_fullpath <- all(grepl("play/", ls$fullpath))
  
  expect_true(is_df(ls) & has_fullpath)
})
