open! Core

let main () =
  match Taxi_lib.Opts.parse_cli () with
  | `Opts opts ->
      Taxi_lib.Taxi.run opts
  | `Exit_code code ->
      exit code

let () = main ()
