test_that("install works", {
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
  expect_true(TRUE)
})



test_that("wrappers", {
  skip_on_cran()
  skip_if_offline()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
  
  suppressMessages({  
    x <- mc_alias_ls("play")
    expect_true(TRUE)
    
    x <- mc_alias_set("anon", "s3.amazonaws.com",
                      access_key = "", secret_key = "")
    expect_true(TRUE)
    
    x <- mc_ls("anon/gbif-open-data-us-east-1")
    expect_true(TRUE)
    
    random_name <- paste0(sample(letters, 12, replace = TRUE), collapse = "")
    play_bucket <- paste0("play/play-", random_name)
    x <- mc_mb(play_bucket)
    expect_true(TRUE)
    
    mc_cp("anon/gbif-open-data-us-east-1/index.html", play_bucket)
    expect_true(TRUE)
    
    x <- mc_du(play_bucket)
    expect_true(TRUE)
    
    x <- mc_anonymous_set(play_bucket, "download")
    expect_true(TRUE)
    
    x <- mc_du("-h")
    expect_true(TRUE)
    
    x <- mc(paste("stat", "anon/gbif-open-data-us-east-1/index.html",
                  paste0(play_bucket, "/index.html")))
    expect_true(TRUE)

    mc_mv(paste0(play_bucket, "/index.html"), paste0(play_bucket, "/gbif.html"))
    expect_true(TRUE)
    
    x <- mc_stat(paste0(play_bucket, "/gbif.html"))
    expect_true(TRUE)
    
    mc_rm(paste0(play_bucket, "/gbif.html"))
    expect_true(TRUE)
    
    x <- mc_rb(play_bucket)
    expect_true(TRUE)
  })    
})