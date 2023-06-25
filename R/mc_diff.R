
mc_diff <- function(dir1, dir2) {
  cmd <- paste("diff", dir1, dir2)
  mc(cmd)
}
