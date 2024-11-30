open! Core

let run opts =
  match opts with Opts.Descendants_opts opts -> Descendants.run opts
