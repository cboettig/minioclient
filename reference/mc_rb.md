# Remove an S3 bucket using mc command

Remove an S3 bucket using mc command

## Usage

``` r
mc_rb(bucket, force = FALSE)
```

## Arguments

- bucket:

  Character string specifying the name of the bucket to remove

- force:

  Delete bucket without confirmation in non-interactive mode

## Value

Returns the list from
[`processx::run()`](http://processx.r-lib.org/reference/run.md), with
components `status`, `stdout`, `stderr`, and `timeout`; invisibly.

## Examples

``` r
if (FALSE) { # interactive()

# Create a new bucket named "my-bucket" on the "play" system
mc_mb("play/my-bucket")
mc_rb("play/my-bucket")
}
```
