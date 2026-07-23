# Display object contents

The cat command returns the contents of the object as a string. This can
be useful when reading smaller files (without first downloading to
disk).

## Usage

``` r
mc_cat(target, offset = 0, tail = 0, flags = "")
```

## Arguments

- target:

  character string specifying the target directory path.

- offset:

  start offset, default 0 if not specified

- tail:

  tail number of bytes at ending of file, default 0 if not specified

- flags:

  additional flags to be passed to the `cat` command. Default is an
  empty string.

## Value

a character string with the contents of the file

## Examples

``` r
if (FALSE) { # interactive()
# upload a file to a bucket and read it back
install_mc()
mc_mb("play/mcr")
mc_cp(system.file(package = "minioclient", "DESCRIPTION"), "play/mcr/DESCRIPTION")
mc_cat("play/mcr/DESCRIPTION")
}
```
