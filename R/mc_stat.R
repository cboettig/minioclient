
mc_stat <- function(targets, flags="") {
  cmd <- paste("stat", flags, targets)
  cmd <- gsub("\\s+", " ", cmd)
  mc(cmd)
}
