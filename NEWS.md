# minioclient 0.0.8

* bug-fix: `install_mc()` could no longer download the client. MinIO moved
  'mc' into its closed-source AIStor product, retired the community download
  host (every `https://dl.min.io/client/mc/release/` URL now returns
  "410 Gone"), and archived the
  [minio/mc](https://github.com/minio/mc) repository. `install_mc()` now
  installs the last release published there,
  `RELEASE.2025-08-13T08-35-41Z`, from its GitHub release assets, so existing
  workflows keep working against a frozen legacy client. Set
  `options(minioclient.version=)` to install a different release tag, or
  `options(minioclient.url=)` to download from a mirror.
* `install_mc()` now downloads to a temporary file alongside the destination
  and only moves it into place on success, so a failed download can no longer
  leave a truncated binary that later looks like an installed client. Failures
  raise an informative error instead of a bare `download.file()` warning.

# minioclient 0.0.7

* bug-fix: on Windows, `mc()` and `mc_sql()` looked for a binary named `mc`
  while `install_mc()` installs `mc.exe`, so the install check never matched
  and interactive sessions were prompted to (re)install on every call. The
  binary name is now resolved through a shared `mc_bin()` helper everywhere.
  Thanks to @mdsumner for the diagnosis
  ([#16](https://github.com/cboettig/minioclient/pull/16),
  [#15](https://github.com/cboettig/minioclient/issues/15)).
* bug-fix: `mc_sql()` returns S3-Select results with `--json`, but `mc`
  reports server-side errors as a JSON payload on stdout while exiting `0`.
  `mc_sql()` now detects that payload and raises an R error instead of
  returning the error object as if it were query results.

# minioclient 0.0.6

* bug-fix: more robust parsing of mc commands e.g. with spaces. ([#7])
* bug-fix: vectorize paths ([#8], [#9])

# minioclient 0.0.5

CRAN-policy based bugfix release. 

* bug-fix: 0.0.4 release introduced unit tests that wrote to `~/.mc`.
  Configuration files are now placed in `minio_path()` directory,
  using OS-specific path from `tools::R_user_dir()`,
  or configured as `options("minioclient.dir")`
* bug-fix: 0.0.4 introduced unit tests that downloaded binary without prompt.
  `install_mc()` will now prompt before install in interactive mode and must
  be called explicitly in batch scripts.
* bug-fix: 0.0.4 some tests may not have fail gracefully when depending on
  external resources.  This is now patched.
  

# minioclient 0.0.4

* Refactored function `mc_ls()` to provide results as a data.frame
* `mc_sql()` function added, which can query CSV, JSON and parquet objects using sql (S3 Select API sql syntax)
* `mc_head()` function added, which reads the first n lines from an object and returns a string
* `mc_cat()` function added, which can be useful when reading or previewing a smaller file directly from the object storage server without first requiring to download it locally

# minioclient 0.0.3

* New function, `mc_config_set()`, can be used to set session tokens [#1](https://github.com/cboettig/minioclient/issues/1).
* `mc_mb()` gains optional arguments, e.g. to not error if bucket exists.
* `mc_rb()` prompts first in interactive mode.

# minioclient 0.0.2

* Added a `NEWS.md` file to track changes to the package.
* Adds helper functions so not everything has to be done by `mc()`
* Extend documentation

