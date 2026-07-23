# Copy files or directories between servers

Most commonly used to upload and download files between local filesystem
and remote S3 store.

## Usage

``` r
mc_cp(from, to = "", recursive = FALSE, flags = "", verbose = FALSE)
```

## Arguments

- from:

  Character string specifying the source file or directory path. Can
  accept a vector of file paths as well.

- to:

  Character string specifying the destination path.

- recursive:

  Logical indicating whether to recursively copy directories. Default is
  `FALSE`.

- flags:

  any additional flags to `cp`

- verbose:

  Logical indicating whether to report files copied. Default is `FALSE`.

## Value

Returns the list from
[`processx::run()`](http://processx.r-lib.org/reference/run.md), with
components `status`, `stdout`, `stderr`, and `timeout`; invisibly.

## Details

see `mc("cp -h")` for details.

## See also

`mc_mirror`

## Examples

``` r
if (FALSE) {
# Copy a file
mc_cp("local/path/to/file.txt", "alias/bucket/path/file.txt")

# Copy a directory recursively
mc_cp("local/directory", "alias/bucket/path/to/directory", recursive = TRUE)

}
```
