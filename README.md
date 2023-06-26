
<!-- README.md is generated from README.Rmd. Please edit that file -->

# minio

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/cboettig/minioclient/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cboettig/minioclient/actions/workflows/R-CMD-check.yaml)
[![R-CMD-check](https://github.com/cboettig/minio/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cboettig/minio/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Installation

You can install the development version of minio from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("cboettig/minioclient")
```

## MinIO Client

At first use, all operations will attempt to install the client if not
already installed. Users can also install latest version of the minio
client can be installed using `install_minio()`.

``` r
library(minioclient)
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
#> play
#>   URL       : https://play.min.io
#>   AccessKey : Q3AM3UQ867SPQQA43P2F
#>   SecretKey : zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG
#>   API       : S3v4
#>   Path      : auto
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
#> Added `anon` successfully.
```

All `mc` functions specify which cloud provider using a filepath
notation, `<ALIAS>/<BUCKET>/<PATH>`. For instance, we can list all
objects found in the bucket `gbif-open-data-us-east-1`, which is a
[public bucket](https://registry.opendata.aws/gbif/) included in the AWS
Open Data Registry:

``` r
mc_ls("anon/gbif-open-data-us-east-1")
#> [2021-05-19 12:25:22 UTC]  32KiB STANDARD index.html
#> [2023-06-26 00:09:37 UTC]     0B occurrence/
```

All `mc` functions can also understand local filesystem paths. Any
absolute path (path starting with `/`), or any relative path not
recognized as a registered alias (Note: be careful not to have local
folders using the same name as remote aliases!) will be interpreted as a
local path. For instance, we can list the contents of the local `R/`
directory:

``` r
mc_ls("R")
#> [2023-06-25 20:39:17 UTC] 2.1KiB install_mc.R
#> [2023-06-25 04:29:43 UTC] 1.2KiB mc.R
#> [2023-06-25 23:54:11 UTC] 1.3KiB mc_alias.R
#> [2023-06-25 23:53:53 UTC] 1.1KiB mc_anonymous.R
#> [2023-06-25 21:24:28 UTC] 1.1KiB mc_cp.R
#> [2023-06-25 21:40:07 UTC]    82B mc_diff.R
#> [2023-06-25 23:09:03 UTC]   371B mc_du.R
#> [2023-06-25 23:46:39 UTC]   992B mc_ls.R
#> [2023-06-25 21:33:07 UTC]   299B mc_mb.R
#> [2023-06-25 20:34:01 UTC] 1.5KiB mc_mirror.R
#> [2023-06-25 23:45:37 UTC] 1.0KiB mc_mv.R
#> [2023-06-25 21:32:46 UTC]   351B mc_rb.R
#> [2023-06-25 20:33:26 UTC]  1020B mc_rm.R
#> [2023-06-25 21:41:30 UTC]   125B mc_stat.R
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
#> 1 gbif.html  file    31.6K rw-r--r--   2023-06-26 00:09:39 cboe… cboe…     66307
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
#> Bucket created successfully `play/play-xsudiblnvyfc`.
```

We can copy files or directories to the remote bucket:

``` r
mc_cp("anon/gbif-open-data-us-east-1/index.html", play_bucket)
mc_cp("R/", play_bucket, recursive = TRUE, verbose = TRUE)
#> `/home/cboettig/cboettig/minio/R/install_mc.R` -> `play/play-xsudiblnvyfc/install_mc.R`
#> `/home/cboettig/cboettig/minio/R/mc.R` -> `play/play-xsudiblnvyfc/mc.R`
#> `/home/cboettig/cboettig/minio/R/mc_alias.R` -> `play/play-xsudiblnvyfc/mc_alias.R`
#> `/home/cboettig/cboettig/minio/R/mc_anonymous.R` -> `play/play-xsudiblnvyfc/mc_anonymous.R`
#> `/home/cboettig/cboettig/minio/R/mc_cp.R` -> `play/play-xsudiblnvyfc/mc_cp.R`
#> `/home/cboettig/cboettig/minio/R/mc_diff.R` -> `play/play-xsudiblnvyfc/mc_diff.R`
#> `/home/cboettig/cboettig/minio/R/mc_du.R` -> `play/play-xsudiblnvyfc/mc_du.R`
#> `/home/cboettig/cboettig/minio/R/mc_ls.R` -> `play/play-xsudiblnvyfc/mc_ls.R`
#> `/home/cboettig/cboettig/minio/R/mc_mb.R` -> `play/play-xsudiblnvyfc/mc_mb.R`
#> `/home/cboettig/cboettig/minio/R/mc_mirror.R` -> `play/play-xsudiblnvyfc/mc_mirror.R`
#> `/home/cboettig/cboettig/minio/R/mc_mv.R` -> `play/play-xsudiblnvyfc/mc_mv.R`
#> `/home/cboettig/cboettig/minio/R/mc_rb.R` -> `play/play-xsudiblnvyfc/mc_rb.R`
#> `/home/cboettig/cboettig/minio/R/mc_rm.R` -> `play/play-xsudiblnvyfc/mc_rm.R`
#> `/home/cboettig/cboettig/minio/R/mc_stat.R` -> `play/play-xsudiblnvyfc/mc_stat.R`
#> Total: 0 B, Transferred: 12.54 KiB, Speed: 296.32 KiB/s
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
#> 44KiB    15 objects  play-xsudiblnvyfc
```

We can also adjust permissions for anonymous access:

``` r
mc_anonymous_set(play_bucket, "download")
#> Access permission for `play/play-xsudiblnvyfc` is set to `download`
```

Public objects can be accessed directly over HTTPS connection using the
endpoint URL, bucket name and path:

``` r
bucket <-  basename(play_bucket) # strip alias from path
# use full domain name as prefix instead:
public_url <- paste0("https://play.min.io/", bucket, "/index.html")
download.file(public_url, "index.html", quiet = TRUE)
```

## Authenticated clients

## Additional functionality

Any command supported by the minio client can be accessed using the
function `mc()`. This function can be used in place of any of the above
methods, or to access additional methods where no wrapper exists, see
`mc("-h")` for complete list.  
R functions such as `mc_ls()` are merely helpful wrappers around the
more generic `mc()` utility, e.g. `mc("ls play")` is equivalent to
`mc_ls("play")`. Providing helper methods allows tab-completion
discovery of functions, R-based documentation, and improved handling of
display behavior (e.g. `verbose=FALSE` by default on certain commands.)
See [official mc client
docs](https://docs.min.io/docs/minio-client-quickstart-guide.html) for
details.

In addition to usual R documentation, users can display full help
information for any method using the argument `"-h"`. This includes
details on optional flags and further examples.

``` r
mc_du("-h")
#> NAME:
#>   mc du - summarize disk usage recursively
#> 
#> USAGE:
#>   mc du [FLAGS] TARGET
#> 
#> FLAGS:
#>   --depth value, -d value       print the total for a folder prefix only if it is N or fewer levels below the command line argument (default: 0)
#>   --recursive, -r               recursively print the total for a folder prefix
#>   --rewind value                include all object versions no later than specified date
#>   --versions                    include all object versions
#>   --encrypt-key value           encrypt/decrypt objects (using server-side encryption with customer provided keys)
#>   --config-dir value, -C value  path to configuration folder (default: "/home/cboettig/.mc")
#>   --quiet, -q                   disable progress bar display
#>   --no-color                    disable color theme
#>   --json                        enable JSON lines formatted output
#>   --debug                       enable debug output
#>   --insecure                    disable SSL certificate verification
#>   --limit-upload value          limits uploads to a maximum rate in KiB/s, MiB/s, GiB/s. (default: unlimited)
#>   --limit-download value        limits downloads to a maximum rate in KiB/s, MiB/s, GiB/s. (default: unlimited)
#>   --help, -h                    show help
#>   
#> ENVIRONMENT VARIABLES:
#>   MC_ENCRYPT_KEY: list of comma delimited prefix=secret values
#> 
#> EXAMPLES:
#>   1. Summarize disk usage of 'jazz-songs' bucket recursively.
#>      $ mc du s3/jazz-songs
#> 
#>   2. Summarize disk usage of 'louis' prefix in 'jazz-songs' bucket upto two levels.
#>      $ mc du --depth=2 s3/jazz-songs/louis/
#> 
#>   3. Summarize disk usage of 'jazz-songs' bucket at a fixed date/time
#>      $ mc du --rewind "2020.01.01" s3/jazz-songs/
#> 
#>   4. Summarize disk usage of 'jazz-songs' bucket with all objects versions
#>      $ mc du --versions s3/jazz-songs/
```

We can now use arbitrary `mc` commands (see
[quickstart](https://docs.min.io/docs/minio-client-quickstart-guide.html)).
For example, examine file information to confirm that eTags (md5sums
here) match for these objects:

``` r
mc(paste("stat", "anon/gbif-open-data-us-east-1/index.html", paste0(play_bucket, "/index.html")))
#> Name      : index.html
#> Date      : 2021-05-19 12:25:22 UTC 
#> Size      : 32 KiB 
#> ETag      : b3c8ed2b99c181bd763d742025a7340d 
#> VersionID : QgZ8OTH0gdcSbpj2yTl9tINxi_4thnj1 
#> Type      : file 
#> Metadata  :
#>   Content-Type: text/html 
#> Replication Status: REPLICA 
#> Name      : index.html
#> Date      : 2023-06-26 00:09:40 UTC 
#> Size      : 32 KiB 
#> ETag      : b3c8ed2b99c181bd763d742025a7340d 
#> Type      : file 
#> Metadata  :
#>   Content-Type: text/html
```
