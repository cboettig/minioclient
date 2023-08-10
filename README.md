
<!-- README.md is generated from README.Rmd. Please edit that file -->

# minio

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/cboettig/minioclient/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cboettig/minioclient/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Rationale

There are numerous packages that already interface with the AWS S3
protocol for object storage. Most rely directly on calls to the
low-level [S3 REST
API](https://docs.aws.amazon.com/AmazonS3/latest/API/Welcome.html)
through R packages such as `curl` or `httr`, which requires significant
amounts of code to provide high-level functionality (e.g. handling
authentication, paging over results, parsing returned XML), and is thus
prone to inefficiency and bugs. Many also implicitly assume that Amazon
is the underlying provider, making it difficult or impossible to work
with a substantial and growing number of object stores now conform to
the AWS S3 standard. These include NSF’s
[OpenStorageNetwork](https://www.openstoragenetwork.org),
[Jetstream2](https://docs.jetstream-cloud.org/overview/overview-doc/)
(both based on open source [Redhat
CEPH](https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/1.3/html/object_gateway_guide_for_red_hat_enterprise_linux/object_gateway_s3_api)),
[NCAR’s Stratus](https://arc.ucar.edu/knowledge_base/70549594) (based on
Western Digital S3), and [MinIO Servers](https://min.io) (another open
source implementation popular with companies and developers), as well as
Google Cloud Storage’s S3 compatibility mode.

In contrast, the MinIO Client, an [open-source,
AGPL-v3](https://github.com/minio/mc/) software developed in the Go
language by the MinIO team, provides a high-performance utility with
intuitive design for working across multiple cloud-based object stores
as well as local filesystems. This package provides a thin R wrapper
around that client – maximizing performance and minimizing potential for
maintenance and bugs. A helper utility provides a convenient way to
install and update the golang binary across operating systems and
architectures. The client supports parallel threads by default,
intuitive handling of bucket permissions such as granting or revoking
anonymous access, and persistent configurations across multiple clouds.
After struggling against the limitations of many different R wrappers
for S3 object stores, this is now my go-to.

## Installation

You can install the development version of `minioclient` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("cboettig/minioclient")
```

## MinIO Client

At first use, all operations will attempt to install the client (after
prompting) if not already installed. Users can also install latest
version of the minio client can be installed using `install_mc`.

``` r
library(minioclient)
install_mc()
```

The MinIO client is designed to support multiple endpoints for cloud
storage, including AWS, Google Cloud Storage (via S3-compatibility), and
other S3 compatible clients such as open source MinIO or Redhat CEPH
storage systems. MinIO uses a syntax based around *aliases* to allow
access across multiple platforms. Aliases can be configured using access
key pairs to allow authenticated access.

### Aliases

By default, the client comes pre-configured with credentials for the
MinIO `play` platform, designed for public experimental storage and
examples. We can use `mc_alias_ls()` to see all clients, specify the
client we want:

``` r
mc_alias_ls("play")
```

Some S3 object storage systems allow access without credentials.
Confusingly, attempting to access public data with invalid credentials
will still fail, so we need to specify an anonymous endpoint with no
credentials. By default, `mc_alias_set` will seek to use
`AWS_S3_ENDPOINT`, `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in
your environment, if set. This allows `minioclient` to be used in
scripts with authentication keys passed in securely as environmental
variables. To set an anonymous access, simply indicate empty
credentials, like so:

``` r
mc_alias_set("anon", "s3.amazonaws.com", access_key = "", secret_key = "")
```

Configuration of aliases is stored in a persistent configuration file,
so aliases need be created only once on a given machine. All `mc`
functions specify which cloud provider using a filepath notation,
`<ALIAS>/<BUCKET>/<PATH>`. For instance, we can list all objects found
in the bucket `gbif-open-data-us-east-1`, which is a [public
bucket](https://registry.opendata.aws/gbif/) included in the AWS Open
Data Registry:

``` r
mc_ls("anon/gbif-open-data-us-east-1")
#> [1] "index.html"  "occurrence/"
```

All `mc` functions can also understand local filesystem paths. Any
absolute path (path starting with `/`), or any relative path not
recognized as a registered alias (Note: be careful not to have local
folders using the same name as remote aliases!) will be interpreted as a
local path. For instance, we can list the contents of the local `R/`
directory:

``` r
mc_ls("R")
#>  [1] "install_mc.R"    "mc.R"            "mc_alias.R"      "mc_anonymous.R" 
#>  [5] "mc_cat.R"        "mc_config_set.R" "mc_cp.R"         "mc_diff.R"      
#>  [9] "mc_du.R"         "mc_head.R"       "mc_ls.R"         "mc_mb.R"        
#> [13] "mc_mirror.R"     "mc_mv.R"         "mc_rb.R"         "mc_rm.R"        
#> [17] "mc_sql.R"        "mc_stat.R"
```

## Uploads & Downloads

This notation makes it easy to move data between local and remote
systems, or even between two remote systems. Let’s copy the `index.html`
file from GBIF to our local file system.

``` r
mc_cp("anon/gbif-open-data-us-east-1/index.html", "gbif.html")
```

Just to prove this is indeed a local copy, we can list local directory:

``` r
fs::file_info("gbif.html")
#> # A tibble: 1 × 18
#>   path       type     size permissions modification_time   user  group device_id
#>   <fs::path> <fct> <fs::b> <fs::perms> <dttm>              <chr> <chr>     <dbl>
#> 1 gbif.html  file    31.6K rw-r--r--   2023-08-10 18:33:12 cboe… cboe…     66307
#> # ℹ 10 more variables: hard_links <dbl>, special_device_id <dbl>, inode <dbl>,
#> #   block_size <dbl>, blocks <dbl>, flags <int>, generation <dbl>,
#> #   access_time <dttm>, change_time <dttm>, birth_time <dttm>
```

For any object store where we have adequate permissions, we can create
new buckets:

``` r
random_name <- paste0(sample(letters, 12, replace = TRUE), collapse = "")
play_bucket <- paste0("play/play-", random_name)

mc_mb(play_bucket)
#> Bucket created successfully `play/play-nwqvinphaeoh`.
```

We can copy files or directories to the remote bucket:

``` r
mc_cp("anon/gbif-open-data-us-east-1/index.html", play_bucket)
mc_cp("R/", play_bucket, recursive = TRUE, verbose = TRUE)
#> `/home/cboettig/cboettig/minioclient/R/mc.R` -> `play/play-nwqvinphaeoh/mc.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_alias.R` -> `play/play-nwqvinphaeoh/mc_alias.R`
#> `/home/cboettig/cboettig/minioclient/R/install_mc.R` -> `play/play-nwqvinphaeoh/install_mc.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_anonymous.R` -> `play/play-nwqvinphaeoh/mc_anonymous.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_cat.R` -> `play/play-nwqvinphaeoh/mc_cat.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_config_set.R` -> `play/play-nwqvinphaeoh/mc_config_set.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_cp.R` -> `play/play-nwqvinphaeoh/mc_cp.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_diff.R` -> `play/play-nwqvinphaeoh/mc_diff.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_du.R` -> `play/play-nwqvinphaeoh/mc_du.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_head.R` -> `play/play-nwqvinphaeoh/mc_head.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_ls.R` -> `play/play-nwqvinphaeoh/mc_ls.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_mb.R` -> `play/play-nwqvinphaeoh/mc_mb.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_mirror.R` -> `play/play-nwqvinphaeoh/mc_mirror.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_mv.R` -> `play/play-nwqvinphaeoh/mc_mv.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_rb.R` -> `play/play-nwqvinphaeoh/mc_rb.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_rm.R` -> `play/play-nwqvinphaeoh/mc_rm.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_sql.R` -> `play/play-nwqvinphaeoh/mc_sql.R`
#> `/home/cboettig/cboettig/minioclient/R/mc_stat.R` -> `play/play-nwqvinphaeoh/mc_stat.R`
#> Total: 0 B, Transferred: 21.60 KiB, Speed: 417.13 KiB/s
```

Note the use of `recursive = TRUE` to transfer all objects matching the
pattern. In S3 object stores, file paths are really just prefixes, thus
this query includes not only everything in the `R` folder, but also
`README.md`, since it also matches the prefix. (Had we used the prefix
`R/`, `README.md` would not be matched and the R scripts would go
directly into `play_bucket` root instead of an `R/` sub-path.)

We can examine disk usage of remote objects or directories:

``` r
mc_du(play_bucket)
```

We can also adjust permissions for anonymous access:

``` r
mc_anonymous_set(play_bucket, "download")
```

Public objects can be accessed directly over HTTPS connection using the
endpoint URL, bucket name and path:

``` r
bucket <-  basename(play_bucket) # strip alias from path
# use full domain name as prefix instead:
public_url <- paste0("https://play.min.io/", bucket, "/index.html")
download.file(public_url, "index.html", quiet = TRUE)
```

## Additional functionality

Any command supported by the minio client can be accessed using the
function `mc()`. This function can be used in place of any of the above
methods, or to access additional methods where no wrapper exists, see
`mc("-h")` for complete list. R functions such as `mc_ls()` are merely
helpful wrappers around the more generic `mc()` utility,
e.g. `mc("ls play")` is equivalent to `mc_ls("play")`. Providing helper
methods allows tab-completion discovery of functions, R-based
documentation, and improved handling of display behavior
(e.g. `verbose=FALSE` by default on certain commands.) See [official mc
client
docs](https://min.io/docs/minio/linux/reference/minio-mc.html?ref=docs-redirect)
for details.

In addition to usual R documentation, users can display full help
information for any method using the argument `"-h"`. This includes
details on optional flags and further examples.

``` r
mc_du("-h")
```

We can now use arbitrary `mc` commands (see
[quickstart](https://min.io/docs/minio/linux/reference/minio-mc.html?ref=docs-redirect)).
For example, examine file information to confirm that eTags (md5sums
here) match for these objects:

``` r
mc(paste("stat", "anon/gbif-open-data-us-east-1/index.html", paste0(play_bucket, "/index.html")))
```
