test_that("mc_bin() is OS-appropriate and consistent across install/lookup", {
  # Windows ships the binary as mc.exe; everything else as mc.
  expect_equal(mc_bin("windows"), "mc.exe")
  expect_equal(mc_bin("linux"), "mc")
  expect_equal(mc_bin("darwin"), "mc")

  # Regression guard (Windows re-install loop): the name mc() looks for
  # must match the name install_mc() writes. Both go through mc_bin(),
  # so exercise that they agree for each OS install_mc() can target.
  for (os in c("windows", "linux", "darwin")) {
    install_bin <- switch(os, "windows" = "mc.exe", "mc")
    expect_equal(mc_bin(os), install_bin)
  }
})
