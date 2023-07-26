is_df <- function(x)
    all(class(x) == c("tbl_df", "tbl", "data.frame")) &
    is.numeric(x$bytes) &
    nrow(x) > 0 &
    all(nchar(x$key) > 0) &
    "POSIXct" %in% class(x$last_modified)


test_that("mc_ls works for listing files at minio play server", {
  
  skip_on_cran()
  skip_if_offline()  
  
  ls <- mc_ls("play/")
  expect_true(is_df(ls))
})

test_that("mc_ls works for listing files locally", {
  
  skip_on_cran()
  skip_if_offline()  
  
  ls <- mc_ls(getwd())
  expect_true(is_df(ls))
})

test_that("mc_ls works for listing files recursively locally", {
  
  skip_on_cran()
  skip_if_offline()  
  
  ls <- mc_ls(getwd(), recursive = TRUE)
  
  expect_true(is_df(ls))
})

test_that("mc_ls provides fullpath", {
  
  skip_on_cran()
  skip_if_offline()  
  
  ls <- mc_ls("play/")
  has_fullpath <- all(grepl("play", ls$fullpath))
  
  expect_true(is_df(ls) & has_fullpath)
})
