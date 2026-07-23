# Remove files or directories

This function uses the `mc` command to remove files or directories at
the specified target location.

## Usage

``` r
mc_rm(target, recursive = FALSE, flags = "", verbose = FALSE)
```

## Arguments

- target:

  Character string specifying the target file or directory path to be
  removed.

- recursive:

  Logical indicating whether to recursively remove directories. Default
  is `FALSE`.

- flags:

  Additional flags to be passed to the `rm` command. Default is an empty
  string.

- verbose:

  Logical indicating whether to list files removed. Default is `FALSE`.

## Value

Returns the list from
[`processx::run()`](http://processx.r-lib.org/reference/run.md), with
components `status`, `stdout`, `stderr`, and `timeout`; invisibly.

## Details

see `mc("rm -h")` for details.

## Examples

``` r
if (FALSE) { # interactive()

# Remove a file
mc_rm("path/to/file.txt")

# Remove a directory recursively
mc_rm("path/to/directory", recursive = TRUE)
}
```
