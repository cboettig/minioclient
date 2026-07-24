# install the mc client

install the mc client

## Usage

``` r
install_mc(
  os = system_os(),
  arch = system_arch(),
  path = minio_path(),
  force = FALSE
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

## Value

path to the minio binary (invisibly)

## Details

This function is just a convenience wrapper for prebuilt MINIO binaries,
from <https://dl.min.io/client/mc/release/>. Should support Windows,
Mac, and Linux on both Intel/AMD (amd64) and ARM architectures. For
details, see official MINIO docs for your operating system, e.g.
<https://docs.min.io/aistor/installation/macos/>.

NOTE: If you want to install to other than the default location, simply
set the option "minioclient.dir", to the appropriate location of the
directory containing your "mc" binary, e.g.
`options("minioclient.dir" = "~/.mc")`. This is also used as the
location of the config directory. Note that this package will not
automatically use MINIO available on \$PATH (to promote security and
portability in design).

## Examples

``` r
if (FALSE) { # interactive()
install_mc()

# Force upgrade
install_mc(force=TRUE)
}
```
