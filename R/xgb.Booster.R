# Construct an internal xgboost Booster and return a handle to it.
# internal utility function
xgb.Booster.handle <- function(params = list(), cachelist = list(), modelfile = NULL) {
  if (typeof(cachelist) != "list" ||
      !all(vapply(cachelist, inherits, logical(1), what = 'xgb.DMatrix'))) {
    stop("cachelist must be a list of xgb.DMatrix objects")
  }

  handle <- .Call("XGBoosterCreate_R", cachelist, PACKAGE = "pbdXGB")
  if (!is.null(modelfile)) {
    if (typeof(modelfile) == "character") {
      .Call("XGBoosterLoadModel_R", handle, modelfile[1], PACKAGE = "pbdXGB")
    } else if (typeof(modelfile) == "raw") {
      .Call("XGBoosterLoadModelFromRaw_R", handle, modelfile, PACKAGE = "pbdXGB")
    } else if (inherits(modelfile, "xgb.Booster")) {
      bst <- xgb.Booster.complete(modelfile, saveraw = TRUE)
      .Call("XGBoosterLoadModelFromRaw_R", handle, bst$raw, PACKAGE = "pbdXGB")
    } else {
      stop("modelfile must be either character filename, or raw booster dump, or xgb.Booster object")
    }
  }
  class(handle) <- "xgb.Booster.handle"
  if (length(params) > 0) {
    xgb.parameters(handle) <- params
  }
  return(handle)
}

# Convert xgb.Booster.handle to xgb.Booster
# internal utility function
xgb.handleToBooster <- function(handle, raw = NULL) {
  bst <- list(handle = handle, raw = raw)
  class(bst) <- "xgb.Booster"
  return(bst)
}

# Check whether xgb.Booster.handle is null
# internal utility function
is.null.handle <- function(handle) {
  if (is.null(handle)) return(TRUE)

  if (!identical(class(handle), "xgb.Booster.handle"))
    stop("argument type must be xgb.Booster.handle")

  if (.Call("XGCheckNullPtr_R", handle, PACKAGE = "pbdXGB"))
    return(TRUE)

  return(FALSE)
}

# Return a verified to be valid handle out of either xgb.Booster.handle or xgb.Booster
# internal utility function
xgb.get.handle <- function(object) {
  handle <- switch(class(object)[1],
    xgb.Booster = object$handle,
    xgb.Booster.handle = object,
    stop("argument must be of either xgb.Booster or xgb.Booster.handle class")
  )
  if (is.null.handle(handle)) {
    stop("invalid xgb.Booster.handle")
  }
  handle
}


# Extract the number of trees in a model.
# TODO: either add a getter to C-interface, or simply set an 'ntree' attribute after each iteration.
# internal utility function
xgb.ntree <- function(bst) {
  length(grep('^booster', xgb.dump(bst)))
}

