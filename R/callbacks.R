#
# Internal utility functions for callbacks ------------------------------------
#

# Format the evaluation metric string
format.eval.string <- function(iter, eval_res, eval_err = NULL) {
  if (length(eval_res) == 0)
    stop('no evaluation results')
  enames <- names(eval_res)
  if (is.null(enames))
    stop('evaluation results must have names')
  iter <- sprintf('[%d]\t', iter)
  if (!is.null(eval_err)) {
    if (length(eval_res) != length(eval_err))
      stop('eval_res & eval_err lengths mismatch')
    res <- paste0(sprintf("%s:%f+%f", enames, eval_res, eval_err), collapse = '\t')
  } else {
    res <- paste0(sprintf("%s:%f", enames, eval_res), collapse = '\t')
  }
  return(paste0(iter, res))
}

# Extract callback names from the list of callbacks
callback.names <- function(cb_list) {
  unlist(lapply(cb_list, function(x) attr(x, 'name')))
}

# Extract callback calls from the list of callbacks
callback.calls <- function(cb_list) {
  unlist(lapply(cb_list, function(x) attr(x, 'call')))
}

# Add a callback cb to the list and make sure that
# cb.early.stop and cb.cv.predict are at the end of the list
# with cb.cv.predict being the last (when present)
add.cb <- function(cb_list, cb) {
  cb_list <- c(cb_list, cb)
  names(cb_list) <- callback.names(cb_list)
  if ('cb.early.stop' %in% names(cb_list)) {
    cb_list <- c(cb_list, cb_list['cb.early.stop'])
    # this removes only the first one
    cb_list['cb.early.stop'] <- NULL
  }
  if ('cb.cv.predict' %in% names(cb_list)) {
    cb_list <- c(cb_list, cb_list['cb.cv.predict'])
    cb_list['cb.cv.predict'] <- NULL
  }
  cb_list
}

# Sort callbacks list into categories
categorize.callbacks <- function(cb_list) {
  list(
    pre_iter = Filter(function(x) {
        pre <- attr(x, 'is_pre_iteration')
        !is.null(pre) && pre
      }, cb_list),
    post_iter = Filter(function(x) {
        pre <- attr(x, 'is_pre_iteration')
        is.null(pre) || !pre
      }, cb_list),
    finalize = Filter(function(x) {
        'finalize' %in% names(formals(x))
      }, cb_list)
  )
}

# Check whether all callback functions with names given by 'query_names' are present in the 'cb_list'.
has.callbacks <- function(cb_list, query_names) {
  if (length(cb_list) < length(query_names))
    return(FALSE)
  if (!is.list(cb_list) ||
      any(sapply(cb_list, class) != 'function')) {
    stop('`cb_list` must be a list of callback functions')
  }
  cb_names <- callback.names(cb_list)
  if (!is.character(cb_names) ||
      length(cb_names) != length(cb_list) ||
      any(cb_names == "")) {
    stop('All callbacks in the `cb_list` must have a non-empty `name` attribute')
  }
  if (!is.character(query_names) ||
      length(query_names) == 0 ||
      any(query_names == "")) {
    stop('query_names must be a non-empty vector of non-empty character names')
  }
  return(all(query_names %in% cb_names))
}
