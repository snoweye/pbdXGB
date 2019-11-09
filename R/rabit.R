#' Simple interface for rabit MPI C calls.
#'
#' These are used to interface with MPI calls.
#'
#' @details
#' See MPI library for details or \pkg{pbdMPI} for examples.
#'
#' @rdname xgb.rabit
#' @export
xgb.rabit.init = function(){
  ret <- .Call("XGBoosterRabitInit_R", PACKAGE = "pbdXGB")
  invisible(ret)
}

#' @rdname xgb.rabit
#' @export
xgb.rabit.finalize = function(){
  ret <- .Call("XGBoosterRabitFinalize_R", PACKAGE = "pbdXGB")
  invisible(ret)
}

#' @rdname xgb.rabit
#' @export
xgb.rabit.getworldsize = function(){
  ret <- .Call("XGBoosterRabitGetWorldSize_R", PACKAGE = "pbdXGB")
  ret
}

#' @rdname xgb.rabit
#' @export
xgb.rabit.getrank = function(){
  ret <- .Call("XGBoosterRabitGetRank_R", PACKAGE = "pbdXGB")
  ret
}
