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
#' @importClassesFrom Matrix dgCMatrix dgeMatrix
#' @importFrom Matrix colSums
#' @importFrom Matrix sparse.model.matrix
#' @importFrom Matrix sparseVector
#' @importFrom Matrix sparseMatrix
#' @importFrom Matrix t
#' @importFrom data.table data.table
#' @importFrom data.table is.data.table
#' @importFrom data.table as.data.table
#' @importFrom data.table :=
#' @importFrom data.table rbindlist
#' @importFrom data.table setkey
#' @importFrom data.table setkeyv
#' @importFrom data.table setnames
#' @importFrom magrittr %>%
#' @importFrom stringi stri_detect_regex
#' @importFrom stringi stri_match_first_regex
#' @importFrom stringi stri_replace_first_regex
#' @importFrom stringi stri_replace_all_regex
#' @importFrom stringi stri_split_regex
#' @importFrom utils object.size str tail head
#' @importFrom stats predict median
#'
#' @import methods
#' @import xgboost
#' @import pbdMPI
NULL
