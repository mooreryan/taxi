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
  let id_fields_gen =
    Quickcheck.Generator.list_with_length 2
      ( Int.quickcheck_generator
      |> Quickcheck.Generator.filter ~f:(fun n -> n > 0) )
  in
  let end_fields_gen =
    Quickcheck.Generator.list_with_length (num_fields - 2) field_gen
  in
  let line_gen =
    Quickcheck.Generator.map2 id_fields_gen end_fields_gen
      ~f:(fun id_fields end_fields ->
        let lst = List.map ~f:Int.to_string id_fields @ end_fields in
        String.concat (lst @ ["\t|\n"]) ~sep:"\t|\t" )
  in
  line_gen

let%test "split_fields matches the first two fields of Re.split_delim when \
          line is valid" =
  let sep = Re.seq [Re.char '\t'; Re.char '|'; Re.char '\t'] |> Re.compile in
  let split s = Re.split_delim sep s in
  Quickcheck.test ~sexp_of:String.sexp_of_t (line_gen ()) ~f:(fun line ->
      match split line with
      | expected_child_id :: expected_id :: _ ->
          let child_id = ref (-1) in
          let id = ref (-1) in
          split_fields line ~child_id ~id ;
          [%test_result: int] !child_id
            ~expect:(Int.of_string expected_child_id) ;
          [%test_result: int] !id ~expect:(Int.of_string expected_id)
      | _ ->
          split line |> [%sexp_of: string list] |> print_s ;
          assert false ) ;
  true

let%expect_test "split_fields ok" =
  let s = "1\t|\t123\t|\tis\t|\tgood" in
  let child_id = ref (-1) in
  let id = ref (-1) in
  split_fields s ~child_id ~id ;
  print_endline [%string "child_id: %{!child_id#Int}, id: %{!id#Int}"] ;
  [%expect {| child_id: 1, id: 123 |}]

let%expect_test "split_fields tabs within fields" =
  let s = "1\t|\t123\t|\tis\t|\tgood" in
  let child_id = ref (-1) in
  let id = ref (-1) in
  split_fields s ~child_id ~id ;
  print_endline [%string "child_id: %{!child_id#Int}, id: %{!id#Int}"] ;
  [%expect {| child_id: 1, id: 123
   |}]

let%expect_test "split_fields raises if the first field is not a string" =
  let s = "apple\t|\t123\t|\tis\t|\tgood" in
  let child_id = ref (-1) in
  let id = ref (-1) in
  Or_error.try_with (fun () -> split_fields s ~child_id ~id)
  |> [%sexp_of: unit Or_error.t] |> print_s ;
  [%expect {| (Error (Failure "Int.of_string: \"apple\"")) |}]

let%expect_test "split_fields raises if the second field is not a string" =
  let s = "1\t|\tpie\t|\tis\t|\tgood" in
  let child_id = ref (-1) in
  let id = ref (-1) in
  Or_error.try_with (fun () -> split_fields s ~child_id ~id)
  |> [%sexp_of: unit Or_error.t] |> print_s ;
  [%expect {| (Error (Failure "Int.of_string: \"pie\"")) |}]

let%expect_test "split_fields raises if the there is only one field" =
  let s = "1" in
  let child_id = ref (-1) in
  let id = ref (-1) in
  Or_error.try_with (fun () -> split_fields s ~child_id ~id)
  |> [%sexp_of: unit Or_error.t] |> print_s ;
  [%expect
    {| (Error (Failure "we got the wrong number of fields; check your input file!")) |}]

let%expect_test "split_fields tabs within fields" =
  let s = "ap\tple\t|\tp\ti\te\t|\tis\t|\tgood" in
  let child_id = ref (-1) in
  let id = ref (-1) in
  Or_error.try_with (fun () -> split_fields s ~child_id ~id)
  |> [%sexp_of: unit Or_error.t] |> print_s ;
  [%expect {| (Error (Failure "Int.of_string: \"ap\\tple\"")) |}]

let%expect_test "split_fields tabs at end of second field" =
  let s = "ap\tple\t|\tp\ti\te\t" in
  let child_id = ref (-1) in
  let id = ref (-1) in
  let result = Or_error.try_with (fun () -> split_fields s ~child_id ~id) in
  result |> [%sexp_of: unit Or_error.t] |> print_s ;
  [%expect {| (Error (Failure "Int.of_string: \"ap\\tple\"")) |}]

let%expect_test "split_fields tabs near end of second field" =
  let s = "ap\tple\t|\tp\ti\t\te\t|\t" in
  let child_id = ref (-1) in
  let id = ref (-1) in
  Or_error.try_with (fun () -> split_fields s ~child_id ~id)
  |> [%sexp_of: unit Or_error.t] |> print_s ;
  [%expect {| (Error (Failure "Int.of_string: \"ap\\tple\"")) |}]

let%expect_test "write_descendants_*" =
  let children_of =
    Hashtbl.of_alist_exn
      (module Int)
      [ (1, [2; 3; 4])
      ; (2, [5; 6])
      ; (3, [])
      ; (4, [7])
      ; (5, [])
      ; (6, [8; 9])
      ; (7, [])
      ; (8, [])
      ; (9, []) ]
  in
  write_descendants_full_output children_of 1 ;
  [%expect
    {|
    1	1	2
    1	1	3
    1	1	4
    1	4	7
    1	7	NA
    1	3	NA
    1	2	5
    1	2	6
    1	6	8
    1	6	9
    1	9	NA
    1	8	NA
    1	5	NA
    |}] ;
  write_descendants_basic_output children_of 1 ;
  [%expect
    {|
    1	1
    1	4
    1	7
    1	3
    1	2
    1	6
    1	9
    1	8
    1	5
    |}] ;
  write_descendants_full_output children_of 2 ;
  [%expect
    {|
    2	2	5
    2	2	6
    2	6	8
    2	6	9
    2	9	NA
    2	8	NA
    2	5	NA
    |}] ;
  write_descendants_basic_output children_of 2 ;
  [%expect {|
      2	2
      2	6
      2	9
      2	8
      2	5
      |}]
