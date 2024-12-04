open! Core
open Cmdliner

let common_docs_sections =
  [ `S Manpage.s_bugs
  ; `P
      "Please report any bugs or issues on GitHub. \
       (https://github.com/mooreryan/taxi/issues)"
  ; `S Manpage.s_see_also
  ; `P
      "For full documentation, please see the GitHub page. \
       (https://github.com/mooreryan/taxi)"
  ; `S Manpage.s_authors
  ; `P "Ryan M. Moore <https://orcid.org/0000-0003-3337-8184>" ]

module Logs : sig
  include module type of struct
    include Logs
  end

  val sexp_of_level : level -> Sexp.t
end = struct
  include Logs

  let sexp_of_level = function
    | App ->
        Sexp.Atom "App"
    | Error ->
        Sexp.Atom "Error"
    | Warning ->
        Sexp.Atom "Warning"
    | Info ->
        Sexp.Atom "Info"
    | Debug ->
        Sexp.Atom "Debug"
end

module Descendants_opts = struct
  type t = {nodes_dmp: string; ids: string; log_level: Logs.level option}
  [@@deriving sexp_of]
end

module Sample_opts = struct
  type t =
    { nodes_dmp: string
    ; rank: string
    ; sample_size: int
    ; log_level: Logs.level option }
  [@@deriving sexp_of]
end

type t = Descendants_opts of Descendants_opts.t | Sample_opts of Sample_opts.t
[@@deriving sexp_of]

let verbose = Logs_cli.level ()

let descendants =
  let info =
    let doc = "get all descendants of a set of taxonomy IDs" in
    let man =
      [ `S Manpage.s_description
      ; `P
          "Given the NCBI nodes.dmp file and a file with one ID per line, \
           return all the descendants of all IDs in the IDs file."
      ; `P
          "The output will have $(i,three tab-separated fields) per line: 1.) \
           starting ID, 2.) parent ID, and 3.) ID."
      ; `P
          "$(b,Field 1):  The starting ID corresponds to one of the IDs in the \
           input ID file.  All lines in the output that start with a given ID \
           descend from that ID in the taxonomy graph specified by the \
           nodes.dmp file."
      ; `P
          "$(b,Field 2):  The parent ID is the (direct) parent of the ID given \
           in field 3.  It is a descendant of the starting ID given in field \
           1."
      ; `P
          "$(b,Field 3):  The ID is the child (direct descendant) of the \
           parent ID given in field 2.  It is also a descendant of the \
           starting ID given in field 1."
      ; `S Manpage.s_examples
      ; `P "=== CLI Usage"
      ; `Pre
          "\\$ taxi descendants /path/to/nodes.dmp /path/to/ids.txt > \
           descendants.tsv" ]
      @ common_docs_sections
    in
    Cmd.info "descendants" ~version:Version.version ~doc ~man ~exits:[]
  in
  let term =
    Term.Syntax.(
      let+ nodes_dmp =
        let doc = "Path to NCBI Taxonomy nodes.dmp file" in
        Arg.(
          required
          & pos 0 (some non_dir_file) None
          & info [] ~docv:"NODES_DMP" ~doc )
      and+ ids =
        let doc = "Path to ID file" in
        Arg.(
          required
          & pos 1 (some non_dir_file) None
          & info [] ~docv:"ID_FILE" ~doc )
      and+ log_level = verbose in
      Descendants_opts {nodes_dmp; ids; log_level} )
  in
  Cmd.v info term

let sample =
  let info =
    let doc = "todo" in
    let man = [] @ common_docs_sections in
    Cmd.info "sample" ~version:Version.version ~doc ~man ~exits:[]
  in
  let term =
    Term.Syntax.(
      let+ nodes_dmp =
        let doc = "Path to NCBI Taxonomy nodes.dmp file" in
        Arg.(
          required
          & pos 0 (some non_dir_file) None
          & info [] ~docv:"NODES_DMP" ~doc )
      and+ rank =
        let doc = "Which rank should I sample? (E.g., genus, species, etc.)" in
        Arg.(required & pos 1 (some string) None & info [] ~docv:"RANK" ~doc)
      and+ sample_size =
        let doc = "Sample size" in
        Arg.(required & pos 2 (some int) None & info [] ~docv:"SIZE" ~doc)
      and+ log_level = verbose in
      Sample_opts {nodes_dmp; rank; sample_size; log_level} )
  in
  Cmd.v info term

let subcommands = [descendants; sample]

let cmd_group =
  let info =
    let doc = "sparkling tools for dealing with the NCBI Taxonomy" in
    let man = common_docs_sections in
    Cmd.info "taxi" ~version:Version.version ~doc ~man ~exits:[]
  in
  Cmd.group info subcommands

let parse_cli () =
  match Cmd.eval_value cmd_group with
  | Ok (`Ok opts) ->
      `Opts opts
  | Ok `Help | Ok `Version ->
      `Exit_code 0
  | Error _ ->
      `Exit_code 1
