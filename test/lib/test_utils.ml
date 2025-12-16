open! Core

let dmp_sep = Re.seq [Re.char '\t'; Re.char '|'; Re.char '\t'] |> Re.compile

let split_dmp_fields_regex s =
  s
  |> String.chop_suffix_exn ~suffix:"\t|\n"
  |> Re.split_delim dmp_sep |> Array.of_list

let%test_unit "empty fields in the middle" =
  let dmp_line = "a\t|\t\t|\tc\t|\n" in
  let expect = [|"a"; ""; "c"|] in
  let result = Array.create "" ~len:3 in
  Taxi_lib.Utils.split_dmp_fields dmp_line ~into:result ;
  [%test_result: string array] result ~expect

let%test_unit "a bunch of random tabs" =
  let dmp_line = "\ta\t|\t\tb\t\t\t\t|\tc\t\t|\n" in
  let expect = [|"\ta"; "\tb\t\t\t"; "c\t"|] in
  let result = Array.create "" ~len:3 in
  Taxi_lib.Utils.split_dmp_fields dmp_line ~into:result ;
  [%test_result: string array] result ~expect

(* This will happen if you're using [In_channen.iter_lines] for example. *)
let%test_unit "missing trailing newline" =
  let dmp_line = "a\t|\t\t|\tc\t|" in
  let expect = [|"a"; ""; "c"|] in
  let result = Array.create "" ~len:3 in
  Taxi_lib.Utils.split_dmp_fields dmp_line ~into:result ;
  [%test_result: string array] result ~expect

let%test_unit "random newlines in the middle" =
  let dmp_line = "a\n\t|\t\nb\n\t|\tc\t|\n" in
  let expect = [|"a\n"; "\nb\n"; "c"|] in
  let result = Array.create "" ~len:3 in
  Taxi_lib.Utils.split_dmp_fields dmp_line ~into:result ;
  [%test_result: string array] result ~expect

let%test_unit "tab right before record end delimiter" =
  let dmp_line = "a\t|\tb\t\t|\n" in
  let expect = [|"a"; "b\t"|] in
  let result = Array.create "" ~len:2 in
  Taxi_lib.Utils.split_dmp_fields dmp_line ~into:result ;
  [%test_result: string array] result ~expect

let%test_unit "one field only" =
  let dmp_line = "a\t|\n" in
  let expect = [|"a"|] in
  let result = Array.create "" ~len:1 in
  Taxi_lib.Utils.split_dmp_fields dmp_line ~into:result ;
  [%test_result: string array] result ~expect

let%test_unit "no fields" =
  let dmp_line = "\t|\n" in
  let expect = [||] in
  let result = Array.create "" ~len:0 in
  Taxi_lib.Utils.split_dmp_fields dmp_line ~into:result ;
  [%test_result: string array] result ~expect

let%test_unit "no fields but expecting some" =
  let dmp_line = "\t|\n" in
  let expect = [|""|] in
  let result = Array.create "" ~len:1 in
  Taxi_lib.Utils.split_dmp_fields dmp_line ~into:result ;
  [%test_result: string array] result ~expect

let%test_unit
    "it is not an error if the user gives an array with more space than fields"
    =
  let dmp_line = "a\t|\tb\t|\n" in
  let expect = [|"a"; "b"; ""; ""; ""|] in
  let result = Array.create "" ~len:5 in
  Taxi_lib.Utils.split_dmp_fields dmp_line ~into:result ;
  [%test_result: string array] result ~expect

let%expect_test "end of record delim in the middle gives an error" =
  let dmp_line = "a\t|\nb\t|\n" in
  let result = Array.create "" ~len:1 in
  let result =
    Or_error.try_with (fun () ->
        Taxi_lib.Utils.split_dmp_fields dmp_line ~into:result )
  in
  result |> [%sexp_of: unit Or_error.t] |> print_s ;
  [%expect
    {|
    (Error
     (Failure
       "Invalid line -- should only see the [tab bar nl] end delimiter at the end of the line: a\t|\
      \nb\t|\
      \n"))
    |}]

let%test_unit "split_dmp_fields matches regex splitting oracle" =
  Quickcheck.test ~sexp_of:String.sexp_of_t Generators.nodes_dmp_line_generator
    ~f:(fun dmp_line ->
      let expected = split_dmp_fields_regex dmp_line in
      let actual = Array.create "" ~len:(Array.length expected) in
      Taxi_lib.Utils.split_dmp_fields dmp_line ~into:actual ;
      [%test_result: string array] actual ~expect:expected )
    ~examples:["a\t|\t\t|\tc\t|\n"; "\t|\t\t|\n"; "\t|\t\t|\t\t|\n"]

(* This might seem like a weird test, but the generator had a bug in which all
   the generated lines ended in [\t|\t\t|\n], that is a field separator directly
   followed by the line end marker. This hid a bug in the split implementation
   that I never hit in practice because I was only ever taking the first couple
   fields of nodes.dmp files in the taxi scripts. I finally did hit this bug in
   practice when writing the 'paths' script, which needs to take each field of
   the names.dmp file. *)
let%test_unit
    "nodes_dmp_line_generator can generate lines where the final field is not \
     empty" =
  Quickcheck.test_can_generate ~sexp_of:String.sexp_of_t
    Generators.nodes_dmp_line_generator ~f:(fun dmp_line ->
      let fields = split_dmp_fields_regex dmp_line in
      let last_element = Array.last fields in
      String.(last_element <> "") )
