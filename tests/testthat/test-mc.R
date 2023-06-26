test_that("install works", {
  skip_if_offline()
  skip_on_cran()
  
  install_mc()
  expect_true(TRUE)
})



test_that("wrappers", {
  skip_on_cran()
  skip_if_offline()
  
  suppressMessages({  
    x <- mc_alias_ls("play")
    expect_true(TRUE)
    
    x <- mc_alias_set("anon", "s3.amazonaws.com",
                      access_key = "", secret_key = "")
    expect_true(TRUE)
    
    x <- mc_ls("anon/gbif-open-data-us-east-1")
    expect_true(TRUE)
    
    mc_cp("anon/gbif-open-data-us-east-1/index.html", "gbif.html")
    expect_true(TRUE)
    
    x <- fs::file_info("gbif.html")
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
    
    bucket <-  basename(play_bucket) # strip alias from path
    expect_true(TRUE)
    
    public_url <- paste0("https://play.min.io/", bucket, "/index.html")
    expect_true(TRUE)
    
    download.file(public_url, "index.html", quiet = TRUE)
    x <- mc_du("-h")
    expect_true(TRUE)
    
    x <- mc(paste("stat", "anon/gbif-open-data-us-east-1/index.html",
                  paste0(play_bucket, "/index.html")))
    expect_true(TRUE)
  
    tmp <- tempfile()
    mc_mirror(play_bucket, tmp)
    expect_true(TRUE)
    
    x <- mc_diff(play_bucket, tmp)
    expect_true(TRUE)
    
    mc_mv("index.html", "gbif.html")
    expect_true(TRUE)
    
    x <- mc_stat("gbif.html")
    expect_true(TRUE)
    
    mc_rm("gbif.html")
    expect_true(TRUE)
    
    mc_rm(tmp, TRUE)
    expect_true(TRUE)

    x <- mc_rb(play_bucket)
    expect_true(TRUE)
  })    
})