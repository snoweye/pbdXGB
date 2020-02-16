# get dmatrix from data, label
# internal helper method
xgb.get.DMatrix <- function(data, label = NULL, missing = NA, weight = NULL) {
  if (inherits(data, "dgCMatrix") || is.matrix(data)) {
    if (is.null(label)) {
      stop("label must be provided when data is a matrix")
    }
    dtrain <- xgb.DMatrix(data, label = label, missing = missing)
    if (!is.null(weight)){
      setinfo(dtrain, "weight", weight)
    }
  } else {
    if (!is.null(label)) {
      warning("xgboost: label will be ignored.")
    }
    if (is.character(data)) {
      dtrain <- xgb.DMatrix(data[1])
    } else if (inherits(data, "xgb.DMatrix")) {
      dtrain <- data
    } else if (inherits(data, "data.frame")) {
      stop("xgboost doesn't support data.frame as input. Convert it to matrix first.")
    } else {
      stop("xgboost: invalid input data")
    }
  }
  return (dtrain)
}
