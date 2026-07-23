# mc_config_set

Edit the config files, e.g. to add a sessionToken

## Usage

``` r
mc_config_set(alias, key, value, json = file.path(minio_path(), "config.json"))
```

## Arguments

- alias:

  A configured alias, see
  [`mc_alias_set()`](https://cboettig.github.io/minioclient/reference/mc_alias_set.md)

- key:

  the parameter name, e.g. `sessionToken`

- value:

  the value to set the parameter to

- json:

  path to the config

## Value

updates configuration and returns silently (`NULL`).

## Examples

``` r
if (FALSE) { # interactive()

mc_config_set("play", key="sessionToken", value="MyTmpSessionToken")
}
```
