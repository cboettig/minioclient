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
  
  res <- mc_stat(target = system.file(package = "minioclient", "R"), 
    details = T, verbose = F)
  
  is_valid <- nrow(res) > 1 && ncol(res) > 1
  
  expect_true(is_valid)
  
})

test_that("mc_stat can return data for local targets (two folders)", {
  
  res <- mc_stat(target = system.file(package = "minioclient", c("R", "man")), 
    details = T, verbose = F)
  
  is_valid <- nrow(res) > 1 && ncol(res) > 1
  
  expect_true(is_valid)
  
})


test_that("mc_stat can return data for target type 'alias'", {
  
  # this can take several seconds before returning
  target <- "play"
  res <- mc_stat(target, details = T, verbose = F)
  is_valid <- nrow(res) > 1 && ncol(res) > 1
  expect_true(is_valid)
  
})

test_that("mc_stat can return data for target type 'bucket'", {
  
  # this can take several seconds before returning
  target <- "s3/openalex"
  
  res <- mc_stat(target, details = T, verbose = F)
  is_valid <- nrow(res) > 1 && ncol(res) > 1
  expect_true(is_valid)
  
})

test_that("mc_stat can return data for target type 'object'", {
  
  # this can take several seconds before returning
  target <- "s3/openalex/README.txt"
  
  res <- mc_stat(target, details = T, verbose = F)
  s1 <- subset(res, property == "metadata.Content-Type")
  s2 <- subset(res, property == "metadata.X-Amz-Server-Side-Encryption")
  is_valid <- s1$value == "text/plain" && s2$value == "AES256"
  expect_true(is_valid)
  
})
