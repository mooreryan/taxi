# Hacking

## Updating the version

- Don't forget to change the version both in the `dune-project` and the `lib/version.ml` file.
- Then, run `dune build` to upate the `*.opam` file(s).

## CI

- Push to `staging` to get a CI check.
- If it's all good and you're ready to release, tag that build commit with the version.
- Download the artifacts.
- Cut a release.

(TODO: Consider automating this?)
