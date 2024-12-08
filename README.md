# Taxi

✨ Sparkling tools for dealing with the NCBI Taxonomy ✨

## Installation

Download one of the precompiled executable files from the release page. There are Linux (x86), and MacOS (x86 and arm) options.

If you are an OCaml programmer, or have a working OCaml environment, feel free to build from source. Note however that the `main` branch may is not necessarily stable or in a working state. It is better to build from a tagged commit.

## Usage

For usage info, see the help page:

```
$ taxi --help
```

For more details, see the help pages for individual subcommands. E.g.,

```
$ taxi descendants --help
```

## Subcommands

- `descendants` -- get descendants of a set of taxonomy IDs
- `filter` -- filter rows based on patterns
- `sample` -- sample taxonomy IDs at a given taxonomic rank

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/taxi)

Copyright (c) 2024 Ryan M. Moore

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.
