# test_that("mc_stat can return data", {
#   res <- mc_stat("s3/openalex", details = T)  
#   
#   is_not_length_one <- 
#     all(names(which(lengths(res$value) != 1)) %in%
#     c("ilm.config.Rules", "notification.config.TopicConfigs"))
#   
#   expect_false(is_not_length_one)
# })

test_that("mc_stat can return data for target type 'local'", {
  
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
  
  res <- mc_stat(target = system.file(package = "minioclient", "R"), 
    details = T, verbose = F)
  
  is_valid <- nrow(res) > 1 && ncol(res) > 1
  
  expect_true(is_valid)
  
})

test_that("mc_stat can return data for local targets (two folders)", {

  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
    
  res <- mc_stat(target = system.file(package = "minioclient", c("R", "man")), 
    details = T, verbose = F)
  
  is_valid <- nrow(res) > 1 && ncol(res) > 1
  
  expect_true(is_valid)
  
})


test_that("mc_stat can return data for target type 'alias'", {
  
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
  
  
  # this can take several seconds before returning
  target <- "play"
  res <- mc_stat(target, details = T, verbose = F)
  is_valid <- nrow(res) > 1 && ncol(res) > 1
  expect_true(is_valid)
  
})

test_that("mc_stat can return data for target type 'bucket'", {
  
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
  
  mc_alias_set("anon", endpoint_url = "https://s3.amazonaws.com", storage = "env")
  
  target <- "anon/gbif-open-data-us-east-1/occurrence"
  
  res <- mc_stat(target, details = T, verbose = F)
  is_valid <- nrow(res) > 1 && ncol(res) > 1
  expect_true(is_valid)
  
})

test_that("mc_stat can return data for target type 'object'", {
  
  skip_if_offline()
  skip_on_cran()
  Sys.setenv("R_USER_DATA_DIR"=tempdir())
  install_mc()
  
  mc_alias_set("anon", endpoint_url = "https://s3.amazonaws.com", storage = "env")
  
  target <- "anon/gbif-open-data-us-east-1/index.html"
  
  res <- mc_stat(target, details = T, verbose = F)
  s1 <- subset(res, property == "metadata.Content-Type")
  s2 <- subset(res, property == "type")
  is_valid <- s1$value == "text/html" && s2$value == "file"
  expect_true(is_valid)
  
})
