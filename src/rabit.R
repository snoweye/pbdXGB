#' @export
xgb.rabit.init = function(){
  ret <- .Call(XGBoosterRabitInit_R)
  invisible(ret)
}

#' @export
xgb.rabit.finalize = function(){
  ret <- .Call(XGBoosterRabitFinalize_R)
  invisible(ret)
}

#' @export
xgb.rabit.getworldsize = function(){
  ret <- .Call(XGBoosterRabitGetWorldSize_R)
  ret
}

#' @export
xgb.rabit.getrank = function(){
  ret <- .Call(XGBoosterRabitGetRank_R)
  ret
}
