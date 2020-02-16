# Simple interface for training an xgboost model that wraps \code{xgb.train}.
# Its documentation is combined with xgb.train.
#
#' @rdname xgb.train
#' @export
xgboost <- function(data = NULL, label = NULL, missing = NA, weight = NULL,
                    params = list(), nrounds,
                    verbose = 1, print_every_n = 1L, 
                    early_stopping_rounds = NULL, maximize = NULL, 
                    save_period = NULL, save_name = "xgboost.model",
                    xgb_model = NULL, callbacks = list(), ...) {

  dtrain <- xgb.get.DMatrix(data, label, missing, weight)

  watchlist <- list(train = dtrain)

  bst <- xgb.train(params, dtrain, nrounds, watchlist, verbose = verbose, print_every_n = print_every_n,
                   early_stopping_rounds = early_stopping_rounds, maximize = maximize,
                   save_period = save_period, save_name = save_name,
                   xgb_model = xgb_model, callbacks = callbacks, ...)
  return(bst)
}


# Various imports
#' @importClassesFrom Matrix dgCMatrix
#' @importFrom data.table rbindlist
#' @importFrom stringi stri_split_regex
#' @importFrom stats predict
#'
#' @import methods
#' @import xgboost
#' @import pbdMPI
#'
NULL
