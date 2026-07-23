# move or rename files or directories between servers

move or rename files or directories between servers

## Usage

``` r
mc_mv(from, to, recursive = FALSE, flags = "", verbose = FALSE)
```

## Arguments

- from:

  Character string specifying the source file or directory path. Can
  accept a vector of file paths as well.

- to:

  Character string specifying the destination path.

- recursive:

  Logical indicating whether to recursively move directories. Default is
  `FALSE`.

- flags:

  any additional flags to `mv`

- verbose:

  Logical indicating whether to report files copied. Default is `FALSE`.

## Value

Returns the list from
[`processx::run()`](http://processx.r-lib.org/reference/run.md), with
components `status`, `stdout`, `stderr`, and `timeout`; invisibly.

## Details

see `mc("mv -h")` for details.

## See also

mc_cp

## Examples

``` r
if (FALSE) { # interactive()

# move a file
mc_mv("local/path/to/file.txt", "alias/bucket/path/file.txt")

# move a directory recursively
mc_mv("local/directory", "alias/bucket/path/to/directory", recursive = TRUE)
}
```
