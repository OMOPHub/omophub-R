# Roxygen renders a method's Arguments section in SIGNATURE order, so a @param
# block that disagrees with the signature still produces correct help. The
# damage is to the source: the next person editing the block sees an argument
# order that contradicts the signature a few lines below, which is how the
# 1.9.0 reorder of MappingsResource$get() came to shift `include_invalid` and
# `vocab_release` out of the positions 1.8.1 had shipped.
#
# For an R6 method, position IS the public contract -- R has no keyword-only
# arguments -- so this guard covers every documented method in the package
# rather than only the ones that have been bitten so far.

#' Extract the R6 generator name a source file defines, or NULL.
generator_name <- function(src) {
  hit <- grep("^[A-Za-z][A-Za-z0-9_.]* <- R6::R6Class\\(", src)
  if (length(hit) != 1) {
    return(NULL)
  }
  sub("^([A-Za-z][A-Za-z0-9_.]*) <- R6::R6Class\\(.*$", "\\1", src[hit])
}

#' @param names, in source order, of the roxygen block directly above `sig`.
documented_params <- function(src, sig) {
  i <- sig - 1
  while (i >= 1 && grepl("^    #'", src[i])) i <- i - 1
  if (i + 1 > sig - 1) {
    return(character(0))
  }
  block <- src[(i + 1):(sig - 1)]
  as.character(
    sub("^    #' @param ([^ ]+).*$", "\\1", grep("^    #' @param ", block, value = TRUE))
  )
}

test_that("every documented R6 method lists @param in signature order", {
  files <- list.files(
    file.path(test_path("..", ".."), "R"),
    pattern = "[.]R$", full.names = TRUE
  )
  expect_gt(length(files), 0)

  checked <- 0
  for (f in files) {
    src <- readLines(f, warn = FALSE)
    gen_name <- generator_name(src)
    if (is.null(gen_name) || !exists(gen_name)) next
    generator <- get(gen_name)

    for (sig in grep("^    [a-zA-Z_.][a-zA-Z0-9_.]* = function\\(", src)) {
      method <- sub("^    ([a-zA-Z_.][a-zA-Z0-9_.]*) = function\\(.*$", "\\1", src[sig])
      fn <- generator$public_methods[[method]]
      if (is.null(fn)) next

      # `...` drops out of BOTH sides: documenting it is good practice but
      # optional, and whether a method does is not an ORDER question. A method
      # that documents nothing is either zero-argument or already caught by
      # R CMD check's undocumented-arguments test.
      documented <- setdiff(documented_params(src, sig), "...")
      actual <- setdiff(as.character(names(formals(fn))), "...")
      if (length(documented) == 0L) next

      expect_equal(
        documented, actual,
        info = sprintf("%s$%s() in %s", gen_name, method, basename(f))
      )
      checked <- checked + 1
    }
  }

  # Guard the guard: a broken scan that silently matched nothing would pass.
  expect_gt(checked, 40)
})
