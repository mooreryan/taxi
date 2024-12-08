# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Added `filter` program
- Added `sample` program

### Changed

- Set two-column basic output as default for descendants program.
- Add a flag (`--full-output`) to toggle the full three-column output. (This was the default previously.)
- Included terminal nodes in the full output of the `descendants` program (their child is labeled as `NA`)

## [2024.0.1] - 2024-12-02

### Changed

- Improved time and memory performance of `descendants` program

## [2024.0.0] - 2024-11-30

- Initial release!

[Unreleased]: https://github.com/mooreryan/gleam_qcheck/compare/2024.0.1...HEAD
[2024.0.1]: https://github.com/mooreryan/gleam_qcheck/releases/tag/2024.0.1
[2024.0.0]: https://github.com/mooreryan/gleam_qcheck/releases/tag/2024.0.0
