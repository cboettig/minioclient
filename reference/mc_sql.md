# Use the S3 variant of SQL to query a minio object

The S3 Select API can be used against CSV and JSON objects stored in
minio. If the minio server runs with MINIO_API_SELECT_PARQUET=on, also
parquet files can be queried.

## Usage

``` r
mc_sql(
  target,
  query = "select * from S3Object",
  recursive = TRUE,
  verbose = FALSE
)
```

## Arguments

- target:

  character alias or path specification at minio for the object (a .csv,
  .json or .parquet file)

- query:

  character string with sql query, by default "select \* from S3Object"

- recursive:

  logical, by default TRUE, allowing a s3 select query to work across a
  minio ALIAS/PATH specification

- verbose:

  logical, by default FALSE

## Value

SQL query results as a `data.frame` of class `tbl_df`

## Details

See <https://min.io/docs/minio/linux/reference/minio-mc/mc-sql.html#>
and <https://github.com/minio/minio/blob/master/docs/select/README.md>

For example "select s.\* from S3Object s limit 10" is valid syntax.

More examples of query syntax here:
<https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-select-sql-reference-select.html>

## Examples

``` r
if (FALSE) { # interactive()
install_mc()
# upload a CSV file
tf <- tempfile()
write.csv(iris, tf, row.names = FALSE)
mc_mb("play/iris")
mc_cp(tf, "play/iris/iris.csv")

# read first 12 lines from the CSV
mc_sql("play/iris/iris.csv", query = "select * from S3Object limit 12")
 
}
```
