# Create a new S3 bucket using mc command

Create a new S3 bucket using mc command

## Usage

``` r
mc_mb(bucket, ignore_existing = TRUE, flags = "", verbose = TRUE)
```

## Arguments

- bucket:

  Character string specifying the name of the bucket to create.

- ignore_existing:

  do not error if bucket already exists

- flags:

  additional flags, see `mc_mb("-h")` for details.

- verbose:

  print output?

## Value

Returns the list from
[`processx::run()`](http://processx.r-lib.org/reference/run.md), with
components `status`, `stdout`, `stderr`, and `timeout`; invisibly.

## Examples

``` r
if (FALSE) { # interactive()

# Create a new bucket named "my-bucket"
mc_mb("play/my-bucket")
}
```
