test_that("mc_ls_tbl works", {
  
  skip_on_cran()
  skip_if_offline()  
  
  ls <- mc_ls_tbl("play/")
  
  is_df <- 
    all(class(ls) == c("tbl_df", "tbl", "data.frame"))
    is.numeric(ls$bytes) &
    nrow(ls) > 0 &
    all(nchar(ls$filename) > 0) &
    "POSIXct" %in% class(ls$timestamp)
    
  expect_true(is_df)
})
