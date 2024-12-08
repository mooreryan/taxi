open! Core

let main () =
  match Taxi_lib.Cli.parse_cli () with
  | `Opts opts ->
      Taxi_lib.Taxi.run opts
  | `Exit_code code ->
      exit code

let () = main ()
