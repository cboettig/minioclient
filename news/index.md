# Changelog

## minioclient 0.0.7

- bug-fix: on Windows,
  [`mc()`](https://cboettig.github.io/minioclient/reference/mc.md) and
  [`mc_sql()`](https://cboettig.github.io/minioclient/reference/mc_sql.md)
  looked for a binary named `mc` while
  [`install_mc()`](https://cboettig.github.io/minioclient/reference/install_mc.md)
  installs `mc.exe`, so the install check never matched and interactive
  sessions were prompted to (re)install on every call. The binary name
  is now resolved through a shared `mc_bin()` helper everywhere. Thanks
  to [@mdsumner](https://github.com/mdsumner) for the diagnosis
  ([\#16](https://github.com/cboettig/minioclient/pull/16),
  [\#15](https://github.com/cboettig/minioclient/issues/15)).
- bug-fix:
  [`mc_sql()`](https://cboettig.github.io/minioclient/reference/mc_sql.md)
  returns S3-Select results with `--json`, but `mc` reports server-side
  errors as a JSON payload on stdout while exiting `0`.
  [`mc_sql()`](https://cboettig.github.io/minioclient/reference/mc_sql.md)
  now detects that payload and raises an R error instead of returning
  the error object as if it were query results.

## minioclient 0.0.6

CRAN release: 2023-11-07

- bug-fix: more robust parsing of mc commands e.g. with spaces. (\[#7\])
- bug-fix: vectorize paths (\[#8\], \[#9\])

## minioclient 0.0.5

CRAN release: 2023-09-02

CRAN-policy based bugfix release.

- bug-fix: 0.0.4 release introduced unit tests that wrote to `~/.mc`.
  Configuration files are now placed in `minio_path()` directory, using
  OS-specific path from
  [`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html), or
  configured as `options("minioclient.dir")`
- bug-fix: 0.0.4 introduced unit tests that downloaded binary without
  prompt.
  [`install_mc()`](https://cboettig.github.io/minioclient/reference/install_mc.md)
  will now prompt before install in interactive mode and must be called
  explicitly in batch scripts.
- bug-fix: 0.0.4 some tests may not have fail gracefully when depending
  on external resources. This is now patched.

## minioclient 0.0.4

CRAN release: 2023-08-09

- Refactored function
  [`mc_ls()`](https://cboettig.github.io/minioclient/reference/mc_ls.md)
  to provide results as a data.frame
- [`mc_sql()`](https://cboettig.github.io/minioclient/reference/mc_sql.md)
  function added, which can query CSV, JSON and parquet objects using
  sql (S3 Select API sql syntax)
- [`mc_head()`](https://cboettig.github.io/minioclient/reference/mc_head.md)
  function added, which reads the first n lines from an object and
  returns a string
- [`mc_cat()`](https://cboettig.github.io/minioclient/reference/mc_cat.md)
  function added, which can be useful when reading or previewing a
  smaller file directly from the object storage server without first
  requiring to download it locally

## minioclient 0.0.3

- New function,
  [`mc_config_set()`](https://cboettig.github.io/minioclient/reference/mc_config_set.md),
  can be used to set session tokens
  [\#1](https://github.com/cboettig/minioclient/issues/1).
- [`mc_mb()`](https://cboettig.github.io/minioclient/reference/mc_mb.md)
  gains optional arguments, e.g. to not error if bucket exists.
- [`mc_rb()`](https://cboettig.github.io/minioclient/reference/mc_rb.md)
  prompts first in interactive mode.

## minioclient 0.0.2

CRAN release: 2023-06-29

- Added a `NEWS.md` file to track changes to the package.
- Adds helper functions so not everything has to be done by
  [`mc()`](https://cboettig.github.io/minioclient/reference/mc.md)
- Extend documentation
