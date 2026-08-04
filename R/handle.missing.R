#' Identify and handle incomplete observations (internal)
#'
#' Estimators in this package index with `which()`, which drops `NA`
#' comparisons silently. An observation with a missing predicted probability
#' therefore contributes nothing to the numerator while its weight remains in
#' the denominator, deflating the estimate in proportion to the missing weight.
#'
#' Discarding incomplete observations is not a neutral repair: it estimates the
#' parameter over the complete-case sub-population rather than the target
#' population. That substitution is consistent only when values are missing
#' completely at random, so it is opt-in via `na.rm` rather than automatic.
#'
#' @param vars Named list of equal-length vectors. `NULL` entries pass through.
#' @param na.rm If `FALSE` (default), incomplete observations are an error. If
#'   `TRUE`, they are removed and a `svyROC_missing_removed` warning is signalled.
#' @param two.class Name of the element in `vars` holding the response, or
#'   `NULL`. When supplied, the two-class requirement is re-checked *after*
#'   removal -- deletion can empty a class that was present beforehand.
#' @return List with `vars` (coerced, and subset when `na.rm = TRUE`) and
#'   `keep`, the logical mask. Callers holding parallel objects -- replicate
#'   weight matrices, for instance -- subset them with `keep`.
#' @keywords internal
#' @noRd
handle.missing <- function(vars, na.rm = FALSE, two.class = NULL){

  # data[, "x"] on a tibble or data.table yields a 1-column object, whose
  # !is.na() is a matrix; as.vector() keeps the mask a plain logical vector.
  vars <- lapply(vars, function(v) if(is.null(v)) NULL else as.vector(v))
  present <- vars[!vapply(vars, is.null, logical(1))]

  if(length(present) == 0L){return(list(vars = vars, keep = logical(0)))}

  keep <- Reduce(`&`, lapply(present, function(v) !is.na(v)))
  n.missing <- sum(!keep)

  if(n.missing == 0L){return(list(vars = vars, keep = keep))}

  if(!isTRUE(na.rm)){
    stop(n.missing, " of ", length(keep), " observations have a missing response, ",
         "predicted probability or sampling weight. Estimates computed after ",
         "discarding them describe the complete-case sub-population, not the ",
         "population the sampling weights refer to, and are biased unless the ",
         "values are missing completely at random. Address the missingness ",
         "(for example by multiple imputation or non-response adjusted ",
         "weights), or pass na.rm = TRUE to discard these observations ",
         "explicitly.", call. = FALSE)
  }

  warning(warningCondition(
    paste0(n.missing, " of ", length(keep), " observations with a missing response, ",
           "predicted probability or sampling weight removed. The result ",
           "describes the complete-case sub-population."),
    class = "svyROC_missing_removed"))

  vars <- lapply(vars, function(v) if(is.null(v)) NULL else v[keep])

  # Removal can empty a class that passed the earlier two-class check. Without
  # this, the tag inference below would pick the same value for event and
  # non-event and return a plausible-looking 0.5.
  if(!is.null(two.class) && length(table(vars[[two.class]])) != 2){
    stop("After removing observations with missing values the response variable ",
         "no longer has two classes.", call. = FALSE)
  }

  list(vars = vars, keep = keep)
}
