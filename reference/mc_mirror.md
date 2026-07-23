# Mirror files and directories using mc command

This function uses the `mc` command to mirror files and directories from
one location to another.

## Usage

``` r
mc_mirror(
  from,
  to,
  overwrite = FALSE,
  remove = FALSE,
  flags = "",
  verbose = FALSE
)
```

## Arguments

- from:

  Character string specifying the source file or directory path.

- to:

  Character string specifying the destination path.

- overwrite:

  Logical indicating whether to overwrite existing files. Default is
  `FALSE`.

- remove:

  Logical indicating whether to remove extraneous files from the
  destination. Default is `FALSE`.

- flags:

  Additional flags to be passed to the `mirror` command. Default is an
  empty string.

- verbose:

  Logical indicating whether to display verbose output. Default is
  `FALSE`.

## Value

Returns the list from
[`processx::run()`](http://processx.r-lib.org/reference/run.md), with
components `status`, `stdout`, `stderr`, and `timeout`; invisibly.

## Examples

``` r
if (FALSE) { # interactive()

# Mirror files and directories from source to destination
mc_mirror("path/to/source", "path/to/destination")

# Mirror files and directories with overwrite and remove options
mc_mirror("path/to/source", "path/to/destination",
           overwrite = TRUE, remove = TRUE)

# Mirror files and directories with additional flags and verbose output
mc_mirror("path/to/source", "path/to/destination", 
          flags = "--exclude '*.txt'", verbose = TRUE)
}
```
