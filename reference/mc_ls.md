# List files and directories using mc command

This function uses the `mc` command to list files and directories at the
specified target location.

## Usage

``` r
mc_ls(target, recursive = FALSE, details = FALSE)
```

## Arguments

- target:

  character vector specifying the target directory path(s).

- recursive:

  Logical indicating whether to recursively list directories. Default is
  `FALSE`.

- details:

  logical, by default FALSE; if TRUE a data frame with details for the
  directory listing is returned.

## Value

a vector of file or directory names ("keys" in minio parlance) or, if
details is TRUE, a data.frame with the directory listing information

## Examples

``` r
if (FALSE) { # interactive()

# list all buckets on play server
mc_ls("play/")
mc_ls("play", details = TRUE)
}
```
