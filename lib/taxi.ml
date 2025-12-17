open! Core

let run opts =
  match opts with
  | Cli.Descendants_opts opts ->
      Descendants.run opts
  | Cli.Filter_opts opts ->
      Filter.run opts
  | Cli.Paths_opts opts ->
      Paths.run opts
  | Cli.Sample_opts opts ->
      Sample.run opts
