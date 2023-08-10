test_that("mc_cat works", {
  
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
  
  tf <- tempfile()
  write.csv(faithful, tf, row.names = FALSE)
  on.exit(unlink(tf))
  
  mc_mb("play/faithful", verbose = FALSE)
  mc_cp(tf, "play/faithful/faithful.csv")
  
  response <- mc_cat("play/faithful/faithful.csv")
  has_content <- nchar(response) > 0
  con <- textConnection(response)
  on.exit(close(con))
  ff <- read.csv(con)
  
  is_faithful <- nrow(ff) == 272 & ncol(ff) ==2
  
  expect_true(has_content & is_faithful)
})
