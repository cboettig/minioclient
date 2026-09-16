# install the mc client

install the mc client

## Usage

``` r
install_mc(
  os = system_os(),
  arch = system_arch(),
  path = minio_path(),
  force = FALSE,
  version = mc_version()
)
```

## Arguments

- os:

  operating system

- arch:

  architecture

- path:

  destination where binary is installed.

- force:

  install even if binary is already found. Can be used to force upgrade.

- version:

  release tag of the 'mc' client to install. Defaults to the last
  release published under the open-source 'minio/mc' repository.

## Value

path to the minio binary (invisibly)

## Details

This function is just a convenience wrapper for prebuilt MINIO binaries.
MinIO has since moved the client to its closed-source AIStor product:
the former download host, <https://dl.min.io/client/mc/release/>, now
returns "410 Gone", and the <https://github.com/minio/mc> repository has
been archived. This package therefore installs the last release
published there, from its GitHub release assets, so that existing
workflows keep working. The client is frozen at that version and will
receive no further upstream fixes. Should support Windows, Mac, and
Linux on both Intel/AMD (amd64) and ARM architectures.

NOTE: If you want to install to other than the default location, simply
set the option "minioclient.dir", to the appropriate location of the
directory containing your "mc" binary, e.g.
`options("minioclient.dir" = "~/.mc")`. This is also used as the
location of the config directory. Note that this package will not
automatically use MINIO available on \$PATH (to promote security and
portability in design).

Two further options cover the case where the pinned release is no longer
reachable: set `options("minioclient.version")` to install a different
release tag, or `options("minioclient.url")` to give the full URL of an
`mc` binary to download (e.g. an internal mirror).

## Examples

``` r
if (FALSE) { # interactive()
install_mc()

# Force upgrade
install_mc(force=TRUE)
}
```
