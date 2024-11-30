open! Core

(* Taken pretty much directly from the InteinFinder code. *)

(** On systems without the local timezone set up properly (e.g., alpine linux
    docker images), we fallback to UTC timezone. *)
let zone () =
  try Lazy.force Time_float_unix.Zone.local
  with Sys_error _ -> Time_float_unix.Zone.utc

let now_coarse () =
  let now = Time_float_unix.now () in
  Time_float_unix.format now "%Y-%m-%d %H:%M:%S" ~zone:(zone ())

let now () =
  Time_float_unix.to_filename_string ~zone:(zone ()) @@ Time_float_unix.now ()

module Log_reporter = struct
  (* Lightly modified from [Logs_fmt] in the [Logs] package. *)

  (*---------------------------------------------------------------------------
    Copyright (c) 2015 The logs programmers. All rights reserved. Distributed
    under the ISC license, see terms at the end of the file.
    ---------------------------------------------------------------------------*)

  let app_style = `Cyan

  let err_style = `Red

  let warn_style = `Yellow

  let info_style = `Blue

  let debug_style = `Green

  [@@@coverage off]

  (* Coverage is off here as it is taken exactly from Logs. *)
  let pp_header ~pp_h ppf (l, h) =
    match l with
    | Logs.App -> (
      match h with
      | None ->
          ()
      | Some h ->
          Fmt.pf ppf "[%a] " Fmt.(styled app_style string) h )
    | Logs.Error ->
        pp_h ppf err_style (match h with None -> "ERROR" | Some h -> h)
    | Logs.Warning ->
        pp_h ppf warn_style (match h with None -> "WARNING" | Some h -> h)
    | Logs.Info ->
        pp_h ppf info_style (match h with None -> "INFO" | Some h -> h)
    | Logs.Debug ->
        pp_h ppf debug_style (match h with None -> "DEBUG" | Some h -> h)

  [@@@coverage on]

  let pp_exec_header =
    let pp_h ppf style h =
      Fmt.pf ppf "%a [%s] " Fmt.(styled style string) h (now_coarse ())
    in
    pp_header ~pp_h

  let reporter ?(pp_header = pp_exec_header) ?app ?dst () =
    Logs.format_reporter ~pp_header ?app ?dst ()

  let pp_header =
    let pp_h ppf style h = Fmt.pf ppf "[%a]" Fmt.(styled style string) h in
    pp_header ~pp_h
end

let set_up_logging log_level =
  Logs.set_reporter @@ Log_reporter.reporter () ;
  Fmt_tty.setup_std_outputs () ;
  Logs.set_level log_level
