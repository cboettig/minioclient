
<!-- README.md is generated from README.Rmd. Please edit that file -->

# minio

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/cboettig/minio/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cboettig/minio/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

*Currently this only a very primitive wrapper.* *Interface will likely
change in future!* See [official mc client
docs](https://docs.min.io/docs/minio-client-quickstart-guide.html) for
details

## Installation

You can install the development version of minio from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("cboettig/minio")
```

## mc

For first-time use on any given machine, you will also have to install
the client: (Currently supports Linux amd64 only; others to come)

``` r
library(minio)
install_mc()
#> /home/cboettig/.local/share/R/mc/mc
## basic example code
```

If you have set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in your
environment, (and `AWS_S3_ENDPOINT` if using a different endpoint than
the default Amazon S3), then you can set an alias with no arguments:

``` r
mc_alias_set()
```

You can also pass `alias`, `access_key`, `secret_key`, and `endpoint` as
arguments. `alias` is just a short-hand for this endpoint – remember,
`mc` client is able to happily work across many different endpoints in
concert, including MINIO-based servers, also GCS, AWS, and others. The
default alias (if none is given) will be `minio`. This step also needs
to only be done once per machine, the `mc` client will remember these
credentials securely (even if environmental variables are later
changed.)

We can now use arbitrary `mc` commands (see
[quickstart](https://docs.min.io/docs/minio-client-quickstart-guide.html))

For instance, we can list all buckets accessible to our credentials at
this client:

``` r
mc("ls minio")
```

Browse buckets by showing path information:

``` r
mc("ls minio/neon4cast-scores")
```

The minio client offers high-performance operations from one cloud
storage platform to another, and can also operate on the local disk.  
For instance, w can mirror the `neon4cast-scores` bucket from the EFI
server (configured here as `minio` alias) to somewhere on the local
disk, e.g.  to `tempfile()`. Local paths omit any alias

``` r
local_dir <- tempfile()
mc(paste("mirror minio/neon4cast-scores", local_dir))

unlink(local_dir) # tidy up
```

The `mc` client includes many simple, powerful operations.  
These are all described in the official
[quickstart](https://docs.min.io/docs/minio-client-quickstart-guide.html)
