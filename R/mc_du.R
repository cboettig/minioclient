#' Show disk usage for a target path
#' 
#' @param target alias/bucket to list
#' @param flags optional additional flags
#' @inherit mc return
#' @details for more help, run `mc_du("-h")`
#' @examplesIf interactive()
#' 
#' # create a new bucket
#' mc_mb("play/minioclient-test")
#' 
#' # no disk usage on new bucket
#' mc_du("play/minioclient-test")
#' 
#' # clean up
#' mc_rb("play/minioclient-test")
#' }
#' @export
mc_du <- function(target, flags="") {
  cmd <- paste("du", flags, target)
  cmd <- gsub("\\s+", " ", cmd)
  mc(cmd)
}
