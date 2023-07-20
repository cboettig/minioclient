test_that("mc_head works", {
  skip_on_cran()
  skip_if_offline()  

  h <- mc_head("play/email/password_reset.html", n = 10)
  is_ok <- nrow(h) == 10
  expect_true(is_ok)
})
