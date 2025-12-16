open! Core

let rank_generator =
  let ranks =
    [ "biotype"
    ; "clade"
    ; "class"
    ; "cohort"
    ; "family"
    ; "forma"
    ; "forma specialis"
    ; "genotype"
    ; "genus"
    ; "infraclass"
    ; "infraorder"
    ; "isolate"
    ; "kingdom"
    ; "morph"
    ; "no rank"
    ; "order"
    ; "parvorder"
    ; "pathogroup"
    ; "phylum"
    ; "section"
    ; "series"
    ; "serogroup"
    ; "serotype"
    ; "species"
    ; "species group"
    ; "species subgroup"
    ; "strain"
    ; "subclass"
    ; "subcohort"
    ; "subfamily"
    ; "subgenus"
    ; "subkingdom"
    ; "suborder"
    ; "subphylum"
    ; "subsection"
    ; "subspecies"
    ; "subtribe"
    ; "superclass"
    ; "superfamily"
    ; "superkingdom"
    ; "superorder"
    ; "superphylum"
    ; "tribe"
    ; "varietas" ]
  in
  Quickcheck.Generator.of_list ranks

let tax_id_generator =
  Int.quickcheck_generator |> Quickcheck.Generator.filter ~f:(fun n -> n > 0)

let generic_field_generator =
  String.quickcheck_generator
  |> Quickcheck.Generator.filter ~f:(fun s ->
      not (String.is_substring s ~substring:"\t|\t") )
  |> Quickcheck.Generator.filter ~f:(fun s ->
      not (String.is_substring s ~substring:"\t|\n") )

let nodes_dmp_fields_generator =
  (* nodes.dmp has 13 fields *)
  let num_fields = 13 in
  let other_fields_generator =
    Quickcheck.Generator.list_with_length (num_fields - 3)
      generic_field_generator
  in
  Quickcheck.Let_syntax.(
    let%map tax_id = tax_id_generator
    and parent_id = tax_id_generator
    and rank = rank_generator
    and other_fields = other_fields_generator in
    Int.to_string tax_id :: Int.to_string parent_id :: rank :: other_fields )

let nodes_dmp_line_generator =
  Quickcheck.Let_syntax.(
    let%map fields = nodes_dmp_fields_generator in
    String.concat (fields @ ["\t|\n"]) ~sep:"\t|\t" )

let nodes_dmp_lines_generator num_lines =
  Quickcheck.Let_syntax.(
    let%map lines =
      Quickcheck.Generator.list_with_length num_lines nodes_dmp_line_generator
    in
    (* Use [""] as the separator, since the lines are already generated with the
       real end of line separator. *)
    String.concat lines ~sep:"" )

(* TODO: nodes.dmp files should have unique values in the tax_id column. *)
