## Test environments

* local: Ubuntu Linux, R 4.6.1 (`R CMD check --as-cran`)
* GitHub Actions: ubuntu-latest (R-devel, R-release, R-oldrel-1),
  macos-latest (R-release), windows-latest (R-release)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Notes for the CRAN team

This is a bug-fix release. The 0.0.7 version on CRAN is now non-functional
through no fault of the package: MinIO moved the 'mc' client into a
closed-source product, withdrew the download host the package relied on
(`https://dl.min.io/client/mc/release/`, which now returns "410 Gone"), and
archived the upstream repository. `install_mc()` could no longer obtain a
client at all.

This release points `install_mc()` at the binaries attached to the last
release published under the open-source upstream repository, which remain
available. The package therefore continues to work for existing users,
against a client that is frozen at that version. Two options
(`minioclient.version` and `minioclient.url`) let users select a different
release tag or an alternative mirror should those assets also be withdrawn.

As before, no binary is downloaded at install or check time: `install_mc()`
is called only by the user, examples are guarded by `interactive()`, and
tests that reach the network are skipped on CRAN.
