open! Core
open Cmdliner

let int_range_inclusive ~low ~high =
  let parser arg =
    Arg.parser_of_kind_of_string
      ~kind:[%string "an int N such that %{low#Int} <= N <= %{high#Int}"]
      (fun arg ->
        let%bind.Option number = Int.of_string_opt arg in
        if low <= number && number <= high then Some number else None )
      arg
  in
  let printer = Format.pp_print_int in
  Arg.conv (parser, printer)

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
  type t =
    { nodes_dmp: string
    ; ids: string
    ; full_output: bool
    ; log_level: Logs.level option }
  [@@deriving sexp_of]
end

module Filter_opts = struct
  type t =
    { nodes_dmp: string
    ; patterns: string
    ; column: int
    ; log_level: Logs.level option }
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

type t =
  | Descendants_opts of Descendants_opts.t
  | Filter_opts of Filter_opts.t
  | Sample_opts of Sample_opts.t
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
          "There are two variations on the output that can be selected: basic \
           output (default) and full output."
      ; `P
          "$(i,Note!)  If a tax ID that is $(b,not) present in the nodes.dmp \
           file is included in the input file, then that tax ID will be \
           skipped and will $(b,not) be present in the program output."
      ; `P "==== Basic Output ==== "
      ; `P "This is the default output."
      ; `P
          "The output will have $(i,two tab-separated fields) per line: 1.) \
           starting ID, and 2.) ID."
      ; `P
          "$(b,Field 1):  The starting ID corresponds to one of the IDs in the \
           input ID file.  All lines in the output that start with a given ID \
           descend from that ID in the taxonomy graph specified by the \
           nodes.dmp file."
      ; `P
          "$(b,Field 2):  The ID is a descendant if the starting ID.  The node \
           represented by this ID need not be a direct descendant of the \
           starting ID."
      ; `P "==== Full Output ==== "
      ; `P
          "The output will have $(i,three tab-separated fields) per line: 1.) \
           starting ID, 2.) ID, and 3.) child ID."
      ; `P
          "$(b,Field 1):  The starting ID corresponds to one of the IDs in the \
           input ID file.  All lines in the output that start with a given ID \
           descend from that ID in the taxonomy graph specified by the \
           nodes.dmp file."
      ; `P
          "$(b,Field 2):  The ID is a descendant if the starting ID and \
           (direct) parent of the child ID given in field 3.  The node \
           represented by this ID need not be a direct descendant of the \
           starting ID."
      ; `P
          "$(b,Field 3):  The child ID is the child (direct descendant) of the \
           ID given in field 2.  It is also a descendant of the starting ID \
           given in field 1."
      ; `P
          "The 2nd and 3rd fields could be used as input to a graph viewer \
           such as Cytoscape."
      ; `P
          "$(i,Note!)  If a tax ID that represents a terminal node in the \
           taxonomy graph (i.e., a node with no children) is included in the \
           input file, then it will also be included in the program output.  \
           Field 1 and 2 will be the given ID and field 3 will be NA."
      ; `S Manpage.s_examples
      ; `P "==== CLI Usage ===="
      ; `Pre "\\$ taxi descendants nodes.dmp ids.txt > descendants.tsv" ]
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
      and+ full_output =
        let doc = "Output the full 3-column graph" in
        Arg.(value & flag & info ["f"; "full-output"] ~docv:"FULL_OUTPUT" ~doc)
      and+ log_level = verbose in
      Descendants_opts {nodes_dmp; ids; full_output; log_level} )
  in
  Cmd.v info term

let filter =
  let info =
    let doc = "filter nodes.dmp file by field" in
    let man =
      [ `S Manpage.s_description
      ; `P
          "Given a set of patterns and a column in which to search, return all \
           records in the nodes.dmp file that have an exact match in the given \
           column to one of the given patterns."
      ; `P "The patterns file should have one pattern per line." ]
      @ common_docs_sections
    in
    Cmd.info "filter" ~version:Version.version ~doc ~man ~exits:[]
  in
  let term =
    Term.Syntax.(
      let+ nodes_dmp =
        let doc = "Path to NCBI Taxonomy nodes.dmp file" in
        Arg.(
          required
          & pos 0 (some non_dir_file) None
          & info [] ~docv:"NODES_DMP" ~doc )
      and+ patterns =
        let doc = "Path to patterns file" in
        Arg.(
          required
          & pos 1 (some non_dir_file) None
          & info [] ~docv:"PATTERNS" ~doc )
      and+ column =
        let doc = "1-based index of column to check patterns against." in
        Arg.(
          value
          & opt (int_range_inclusive ~low:1 ~high:13) 3
          & info ["c"; "column"] ~docv:"COLUMN" ~doc )
      and+ log_level = verbose in
      Filter_opts {nodes_dmp; patterns; column; log_level} )
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

let subcommands = [descendants; filter; sample]

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
