#' Show disk usage for a target path
#' 
#' @param target alias/bucket to list
#' @param flags optional additional flags
#' @details for more help, run `mc_du("-h")`
#' @examples \dontrun{
#' 
#' mc_mb("play/test")
#' mc_du("play/test")
#' }
#' @export
mc_du <- function(target, flags="") {
  cmd <- paste("du", flags, target)
  cmd <- gsub("\\s+", " ", cmd)
  mc(cmd)
}
