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

