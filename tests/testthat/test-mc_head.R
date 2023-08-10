test_that("mc_head works", {
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
  
  tf <- tempfile()
  write.csv(faithful, tf, row.names = FALSE)
  on.exit(unlink(tf))
  
  mc_mb("play/faithful", verbose = FALSE)
  mc_cp(tf, "play/faithful/faithful.csv")
  
  response <- mc_head("play/faithful/faithful.csv", 6)
  faithful <- read.csv(textConnection(response))
  has_content <- nrow(faithful) == (6 - 1) # header row
  
  expect_true(has_content)
})
