test_that("mc() reports the server's stderr, not a generic processx error", {
  skip_on_cran()
  skip_if_offline()
  Sys.setenv("R_USER_DATA_DIR" = tempdir())
  install_mc()

  # An alias that was never configured makes mc exit non-zero with an
  # explanation on stderr. Before, processx::run() threw first and that
  # explanation was lost behind "System command 'mc' failed".
  err <- tryCatch(
    mc("ls no-such-alias-xyz/no-such-bucket", verbose = FALSE),
    error = function(e) e
  )

  expect_s3_class(err, "error")
  expect_false(inherits(err, "system_command_status_error"))
  expect_true(nzchar(trimws(conditionMessage(err))))
})
