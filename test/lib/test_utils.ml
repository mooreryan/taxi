open! Core
open Taxi_lib.Utils

let dmp_sep = Re.seq [Re.char '\t'; Re.char '|'; Re.char '\t'] |> Re.compile

let split_dmp_fields_regex s =
  s
  |> String.chop_suffix_exn ~suffix:"\t|\n"
  |> Re.split_delim dmp_sep |> Array.of_list

let%test_unit "split_dmp_fields matches regex splitting oracle" =
  Quickcheck.test ~sexp_of:String.sexp_of_t Generators.nodes_dmp_line_generator
    ~f:(fun dmp_line ->
      let expected = split_dmp_fields_regex dmp_line in
      let actual = Array.create "" ~len:(Array.length expected) in
      split_dmp_fields dmp_line ~into:actual ;
      [%test_result: string array] actual ~expect:expected )
