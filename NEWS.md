# svyROC 1.1.1

## Performance

* `wauc()` computed the weighted AUC by materialising dense case x control
  matrices with `outer()`, so memory and time grew with the product of the two
  class sizes. Measured at about 29 bytes per cell, that is ~3.7 GB at
  n = 100,000 and beyond addressable memory at n = 1,000,000, which placed the
  function out of reach of the survey data sets it is intended for.

  It now evaluates the same weighted Mann-Whitney U statistic through the rank
  identity: sort once, accumulate weighted cumulative sums, and group ties so
  they contribute one half. O(n log n) time and O(n) memory. At n = 100,000
  this is 0.20 s and 0.25 GB against 6.55 s and 3.80 GB, returning an identical
  value; n = 1,000,000, which previously could not be attempted, takes 2.43 s.

  The estimator, its tie handling, the tag semantics and every returned field
  are unchanged.

# svyROC 1.1.0

* Added new functions: `ci.wauc()`, `ht.paired()`, and `ht.indep()` to compute confidence intervals and perform hypothesis testing.

# svyROC 1.0.0

* Initial CRAN submission.
