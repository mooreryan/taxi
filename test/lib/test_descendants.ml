open! Core
open Taxi_lib.Descendants

(* nodes.dmp has 13 fields *)
let line_gen ?(num_fields = 13) () =
  let field_gen =
    String.quickcheck_generator
    |> Quickcheck.Generator.filter ~f:(fun s ->
           not (String.is_substring s ~substring:"\t|\t") )
    |> Quickcheck.Generator.filter ~f:(fun s ->
           not (String.is_substring s ~substring:"\t|\n") )
  in
  let fields_gen = Quickcheck.Generator.list_with_length num_fields field_gen in
  let line_gen =
    fields_gen
    |> Quickcheck.Generator.map ~f:(fun fields ->
           String.concat (fields @ ["\t|\n"]) ~sep:"\t|\t" )
  in
  line_gen

let%test "split_fields matches the first two fields of Re.split_delim when \
          line is valid" =
  let sep = Re.seq [Re.char '\t'; Re.char '|'; Re.char '\t'] |> Re.compile in
  let split s = Re.split_delim sep s in
  Quickcheck.test ~sexp_of:String.sexp_of_t (line_gen ()) ~f:(fun line ->
      match split line with
      | expected_child_id :: expected_id :: _ ->
          let child_id = ref "" in
          let id = ref "" in
          split_fields line ~child_id ~id ;
          [%test_result: string] !child_id ~expect:expected_child_id ;
          [%test_result: string] !id ~expect:expected_id
      | _ ->
          split line |> [%sexp_of: string list] |> print_s ;
          assert false ) ;
  true

let%expect_test "split_fields ok" =
  let s = "apple\t|\tpie\t|\tis\t|\tgood" in
  let child_id = ref "" in
  let id = ref "" in
  split_fields s ~child_id ~id ;
  print_endline [%string "child_id: %{!child_id}, id: %{!id}"] ;
  [%expect {| child_id: apple, id: pie |}]

let%expect_test "split_fields tabs within fields" =
  let s = "ap\tple\t|\tp\ti\te\t|\tis\t|\tgood" in
  let child_id = ref "" in
  let id = ref "" in
  split_fields s ~child_id ~id ;
  print_endline [%string "child_id: %{!child_id}, id: %{!id}"] ;
  [%expect {| child_id: ap	ple, id: p	i	e |}]

let%expect_test "split_fields tabs at end of second field" =
  let s = "ap\tple\t|\tp\ti\te\t" in
  let child_id = ref "" in
  let id = ref "" in
  let result = Or_error.try_with (fun () -> split_fields s ~child_id ~id) in
  result |> [%sexp_of: unit Or_error.t] |> print_s ;
  [%expect
    {| (Error (Failure "we got the wrong number of fields; check your input file!")) |}]

let%expect_test "split_fields tabs near end of second field" =
  let s = "ap\tple\t|\tp\ti\t\te\t|\t" in
  let child_id = ref "" in
  let id = ref "" in
  split_fields s ~child_id ~id ;
  print_endline [%string "child_id: %{!child_id}, id: %{!id}"] ;
  [%expect {| child_id: ap	ple, id: p	i		e |}]

let%expect_test _ =
  let children_of =
    Hashtbl.of_alist_exn
      (module String)
      [ ("1", ["2"; "3"; "4"])
      ; ("2", ["5"; "6"])
      ; ("4", ["7"])
      ; ("6", ["8"; "9"]) ]
  in
  descendants children_of "1" ;
  [%expect
    {|
    1	1	2
    1	1	3
    1	1	4
    1	4	7
    1	2	5
    1	2	6
    1	6	8
    1	6	9
    |}] ;
  descendants children_of "2" ;
  [%expect {|
    2	2	5
    2	2	6
    2	6	8
    2	6	9
    |}]
