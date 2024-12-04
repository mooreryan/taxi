open! Core
open! Core_bench

(* randomly selected line from the nodes.dmp file *)
let dmp_line =
  "2305906\t|\t83975\t|\tspecies\t|\tAT\t|\t10\t|\t1\t|\t1\t|\t1\t|\t2\t|\t1\t|\t1\t|\t0\t|\tcode \
   compliant; specified\t|\n"

let fields = Array.create ~len:13 ""
let first_two_fields = Array.create ~len:2 ""
let child_id = ref 0
let id = ref 0

let split_dmp_fields_regex_list s =
  s
  |> String.chop_suffix_exn ~suffix:"\t|\n"
  |> Re.split_delim Test_taxi_lib.Test_utils.dmp_sep

(* This isn't a "correct" splitting of the dump file, but include it to get an
   idea for basic char splitting performance. *)
let split_on_bar s = s |> String.split ~on:'|'
let split_on_bar_take_2 s = List.take (s |> String.split ~on:'|') 2

let () =
  Command_unix.run
    Bench.(
      make_command
        [ Test.create ~name:"split_dmp_fields_regex" (fun () ->
              Test_taxi_lib.Test_utils.split_dmp_fields_regex dmp_line )
        ; Test.create ~name:"split_dmp_fields_regex_list" (fun () ->
              split_dmp_fields_regex_list dmp_line )
        ; Test.create ~name:"split_on_bar" (fun () -> split_on_bar dmp_line)
        ; Test.create ~name:"split_dmp_fields" (fun () ->
              Taxi_lib.Utils.split_dmp_fields dmp_line ~into:fields )
        ; Test.create ~name:"split_dmp_fields (first 2 fields)" (fun () ->
              Taxi_lib.Utils.split_dmp_fields dmp_line ~into:first_two_fields )
        ; Test.create ~name:"descendants split fields (first 2 fields)"
            (fun () ->
              Taxi_lib.Descendants.split_fields dmp_line ~child_id ~id )
        ; Test.create ~name:"split_on_bar_take_2" (fun () ->
              split_on_bar_take_2 dmp_line ) ] )
