# mc alias set

Set a new alias for the minio client, possibly using env var defaults.

## Usage

``` r
mc_alias_set(
  alias = "minio",
  endpoint = Sys.getenv("AWS_S3_ENDPOINT", "s3.amazonaws.com"),
  access_key = Sys.getenv("AWS_ACCESS_KEY_ID"),
  secret_key = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
  scheme = "https"
)
```

## Arguments

- alias:

  a short name for this endpoint, default is `minio`

- endpoint:

  the endpoint domain name

- access_key:

  access key (user), reads from AWS env vars by default

- secret_key:

  secret access key, reads from AWS env vars by default

- scheme:

  https or http (e.g. for local machine only)

## Value

Returns the list from
[`processx::run()`](http://processx.r-lib.org/reference/run.md), with
components `status`, `stdout`, `stderr`, and `timeout`; invisibly.

## References

<https://docs.min.io/aistor/reference/cli/>. Note that keys can be
omitted for anonymous use.

## Examples

``` r
if (FALSE) { # interactive()

mc_alias_set()
}
```
