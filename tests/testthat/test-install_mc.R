test_that("mc_url() points at the archived release assets, not dl.min.io", {
  # MinIO retired the community download host when the client went
  # closed-source: every https://dl.min.io/client/mc/release/ URL now answers
  # "410 Gone". The binaries attached to the last tagged release of the
  # (now archived) minio/mc repo are still served, named mc.<os>-<arch>.<tag>.
  tag <- "RELEASE.2025-08-13T08-35-41Z"
  base <- paste0("https://github.com/minio/mc/releases/download/", tag, "/mc.")

  expect_equal(mc_url("linux", "x86_64", tag),
               paste0(base, "linux-amd64.", tag))
  expect_equal(mc_url("darwin", "aarch64", tag),
               paste0(base, "darwin-arm64.", tag))
  # The Windows asset is the one that carries a trailing ".exe" (verified
  # against the release's asset list); the others have no extension.
  expect_equal(mc_url("windows", "x86_64", tag),
               paste0(base, "windows-amd64.", tag, ".exe"))

  # "mac" is the other spelling install_mc() has always accepted.
  expect_equal(mc_url("mac", "x86_64", tag), mc_url("darwin", "amd64", tag))

  expect_false(grepl("dl.min.io", mc_url("linux", "amd64", tag), fixed = TRUE))
})

test_that("the pinned version is the last open-source mc release", {
  expect_equal(mc_version(), "RELEASE.2025-08-13T08-35-41Z")
  expect_match(mc_url("linux", "amd64"), mc_version(), fixed = TRUE)
})

test_that("both escape hatches are honored when the pin goes stale", {
  withr_version <- options(minioclient.version = "RELEASE.2020-01-01T00-00-00Z")
  on.exit(options(withr_version), add = TRUE)
  expect_equal(mc_version(), "RELEASE.2020-01-01T00-00-00Z")
  expect_match(mc_url("linux", "amd64"), "RELEASE.2020-01-01T00-00-00Z",
               fixed = TRUE)

  withr_url <- options(minioclient.url = "https://example.com/mirror/mc")
  on.exit(options(withr_url), add = TRUE)
  expect_equal(mc_url("linux", "amd64"), "https://example.com/mirror/mc")
})

test_that("a failed download leaves no binary behind", {
  path <- fs::path(tempfile("minioclient"))
  # Nothing is served here, so install_mc() must error rather than leave a
  # stub that later looks like an installed client.
  op <- options(minioclient.url = "https://example.invalid/no/such/mc")
  on.exit(options(op), add = TRUE)

  expect_error(install_mc(path = path), "Failed to download")
  expect_false(file.exists(fs::path(path, mc_bin())))
  expect_false(file.exists(fs::path(path, paste0(mc_bin(), ".download"))))
})
