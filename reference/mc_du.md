# Show disk usage for a target path

Show disk usage for a target path

## Usage

``` r
mc_du(target, flags = "")
```

## Arguments

- target:

  alias/bucket to list

- flags:

  optional additional flags

## Value

Returns the list from
[`processx::run()`](http://processx.r-lib.org/reference/run.md), with
components `status`, `stdout`, `stderr`, and `timeout`; invisibly.

## Details

for more help, run `mc_du("-h")`

## Examples

``` r
if (FALSE) { # interactive()

# create a new bucket
mc_mb("play/minioclient-test")

# no disk usage on new bucket
mc_du("play/minioclient-test")

# clean up
mc_rb("play/minioclient-test")
}
```
