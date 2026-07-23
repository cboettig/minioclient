# mc

The MINIO Client

## Usage

``` r
mc(command, ..., path = minio_path(), verbose = interactive())
```

## Arguments

- command:

  space-delimited text string of an mc command (starting after the mc
  ...)

- ...:

  additional arguments to
  [`processx::run()`](http://processx.r-lib.org/reference/run.md)

- path:

  location where mc executable will be installed. By default will use
  the OS-appropriate storage location.

- verbose:

  print output?

## Value

Returns the list from
[`processx::run()`](http://processx.r-lib.org/reference/run.md), with
components `status`, `stdout`, `stderr`, and `timeout`; invisibly.

## Details

This function forms the basis for all other available commands. This
utility can run any `mc` command supported by the official minio client,
see <https://min.io/docs/minio/linux/reference/minio-mc.html>. The R
package provides wrappers only for the most common use cases, which
provide a more natural R syntax and native documentation.
