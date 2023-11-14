test_that("parsing MC_HOST_* env vars works", {
  
  # replicates tests from 
  # https://github.com/minio/mc/blob/master/cmd/config_test.go#L89
  
  envs <- list(
    test_01 = "https://minio:minio1#23@localhost:9000",
    test_02 = "https://minio:minio123@@localhost:9000",
    test_03 = "https://minio:minio@123@@localhost:9000", # pass is "minio@123@"
    test_04 = "https://localhost:9000", # no credentials
    test_05 = "https://minio:minio123:token@localhost:9000", # triplet
    test_06 = "https://minio:minio@123:token@@localhost:9000", # token is "token@"
    test_07 = "https://minio@localhost:9000", # pass is ""
    test_08 = "https://minio:@localhost:9000", # pass is ""
    test_09 = "https://:@localhost:9000", # login is "", pass is ""
    test_10 = "https://:minio123@localhost:9000", # login is "", pass is "minio123"
    test_11 = "https://:minio123:token@localhost:9000", # login is ""
    test_12 = "https://:minio123:@localhost:9000" # login is "" and token is ""
  )
  
  res <- parse_mc_host_env(envs)
  
  ok_00 <- nrow(res) == 12 && ncol(res) == 8
  
  ok_01 <- with(
    res[res$alias == "test_01",],
      accessKey == "minio" && 
      secretKey == "minio1#23" &&
      is.na(token) && 
      URL == "https://localhost:9000"
  )
  
  # permits @ to be present in pass?
  ok_02 <- with(
    res[res$alias == "test_02",],
      accessKey == "minio" && 
      secretKey == "minio123@" &&
      is.na(token) && 
      URL == "https://localhost:9000"
  )

  ok_03 <- with(
    res[res$alias == "test_03",],
      accessKey == "minio" && 
      secretKey == "minio@123@" &&
      is.na(token) && 
      URL == "https://localhost:9000"
  )
  
  # permits empty credentials triplet?
  ok_04 <- with(
    res[res$alias == "test_04",],
      is.na(accessKey) && 
      is.na(secretKey) &&
      is.na(token) && 
      URL == "https://localhost:9000"
  )
  
  ok_05 <- with(
    res[res$alias == "test_05",],
      accessKey == "minio" && 
      secretKey == "minio123" &&
      token == "token" &&
      URL == "https://localhost:9000"
  )

  ok_06 <- with(
    res[res$alias == "test_06",],
      accessKey == "minio" && 
      secretKey == "minio@123" &&
      token == "token@" &&
      URL == "https://localhost:9000"
  )

  ok_07 <- with(
    res[res$alias == "test_07",],
      accessKey == "minio" && 
      is.na(secretKey) &&
      is.na(token) &&
      URL == "https://localhost:9000"
  )

  ok_08 <- with(
    res[res$alias == "test_08",],
      accessKey == "minio" && 
      is.na(secretKey) &&
      is.na(token) &&
      URL == "https://localhost:9000"
  )

  ok_09 <- with(
    res[res$alias == "test_09",],
      is.na(accessKey) && 
      is.na(secretKey) &&
      is.na(token) &&
      URL == "https://localhost:9000"
  )

  ok_10 <- with(
    res[res$alias == "test_10",],
      is.na(accessKey) && 
      secretKey == "minio123" &&
      is.na(token) &&
      URL == "https://localhost:9000"
  )

  ok_11 <- with(
    res[res$alias == "test_11",],
      is.na(accessKey) && 
      secretKey == "minio123" &&
      token == token &&
      URL == "https://localhost:9000"
  )

  ok_12 <- with(
    res[res$alias == "test_12",],
      is.na(accessKey) && 
      secretKey == "minio123" &&
      is.na(token) &&
      URL == "https://localhost:9000"
  )

  ok_all <- all(c(ok_00, 
    ok_01, ok_02, ok_03, ok_04, ok_05, ok_06, 
    ok_07, ok_08, ok_09, ok_10, ok_11, ok_12
  ))

  expect_true(ok_all)
})

test_that("MC_HOST_* env var values from parameters works (roundtripping)", {
  
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
  
  details <- mc_alias_ls(details = TRUE, show_secret = TRUE)
  d <- details[,c("alias", "URL", "accessKey", "secretKey", "token")]
  colnames(d) <- c("alias", "endpoint_url", "login", "pass", "token")
  
  envs <- unlist(mapply(mc_host_env, 
    d$alias, d$endpoint_url, d$login, d$pass, d$token))
  names(envs) <- gsub(".*?\\.(.*)$", "\\1", names(envs))
  
  parts <- parse_mc_host_env(envs, show_secret = T)
  
  is_ok <- all(
    parts$alias == details$alias,
    parts$URL == details$URL,
    na.omit(parts$accessKey) == na.omit(details$accessKey),
    na.omit(parts$secretKey) == na.omit(details$secretKey),
    na.omit(parts$token) == na.omit(details$token)
  )
  expect_true(is_ok)
})