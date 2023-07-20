test_that("mc_cat works", {
  
  skip_on_cran()
  skip_if_offline()  
  
  cat <- mc_cat("play/email/password_reset.html")
  has_content <- nchar(cat) > 0
  expect_true(has_content)
})
