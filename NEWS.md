# svyROC 1.1.1

## Bug fixes

* Observations with a missing predicted probability were dropped from the
  numerator of `wse()`, `wsp()` and `wauc()` by `which()` while their sampling
  weights remained in the denominator. Sensitivity, specificity and the AUC
  were therefore biased downward in proportion to the missing weight, silently
  and with no warning. For the AUC the distortion was exactly
  `AUCw_complete * (W1_complete/W1_total) * (W0_complete/W0_total)`.
  `wroc()`, `wocp()`, `ci.wauc()`, `ht.paired()`, `ht.indep()` and
  `corrected.wauc()` inherited the same behaviour.

* Handling of missing values was inconsistent between arguments: a missing
  response was deleted case-wise, a missing weight propagated to `NA`, and a
  missing predicted probability was retained.

## User-visible changes

* All estimating functions gain an `na.rm` argument, `FALSE` by default.
  Incomplete observations are now an error rather than being silently
  retained. Passing `na.rm = TRUE` restores complete-case behaviour and
  signals a warning of class `svyROC_missing_removed`.

  This is a deliberate change of default: discarding incomplete observations
  estimates the parameter over the complete-case sub-population rather than
  the population the sampling weights describe, which is consistent only
  under missingness completely at random. Callers who want that substitution
  should now request it explicitly.

* Under `na.rm = TRUE`, the requirement that the response have two classes is
  re-checked after deletion, since removal can empty a class that was present
  beforehand.

# svyROC 1.1.0

* Added new functions: `ci.wauc()`, `ht.paired()`, and `ht.indep()` to compute confidence intervals and perform hypothesis testing.

# svyROC 1.0.0

* Initial CRAN submission.
