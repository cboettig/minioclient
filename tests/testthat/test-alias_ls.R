# NB: cannot vectorize arguments for aliases when using "mc alias ls", 
# only one alias can be "filtered"

test_that("mc_host_env can use settings from ~/.mc/config.json", {
  
  details <- mc_alias_ls("play", details = TRUE, show_secret = TRUE)
  
  mc_host_test <- mc_host_env("test", details$URL, 
    details$accessKey, details$secretKey, details$token)
  
  Sys.setenv("MC_HOST_test" = unname(mc_host_test))
  
  is_ok <- length(mc_ls("test")) > 0
  
  Sys.unsetenv("MC_HOST_test")
  
  expect_true(is_ok)
})

test_that("mc_alias_ls can provide detailed data", {
  res <- mc_alias_ls(alias = "play", details = TRUE)
  is_ok <- res$URL == "https://play.min.io"
  expect_true(is_ok)
})

test_that("mc_alias_ls can list also MC_HOST_* envvar settings", {
  
  play <- mc_alias_ls("play", details = TRUE, show_secret = TRUE)
  
  mc_host_test <- mc_host_env("test", play$URL, 
    play$accessKey, play$secretKey, play$token)
  
  Sys.setenv("MC_HOST_test" = unname(mc_host_test))
  
  test <- mc_alias_ls("test", details = TRUE)
  is_ok <- test$URL == "https://play.min.io"
  
  Sys.unsetenv("MC_HOST_test")
  
  expect_error(mc_alias_ls("test", details = TRUE), regexp = "failed")
  expect_true(is_ok)
})

