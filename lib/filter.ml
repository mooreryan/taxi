open! Core

let read_patterns patterns_file =
  let patterns = Hash_set.create (module String) in
  In_channel.with_file patterns_file ~f:(fun ic ->
      In_channel.iter_lines ic ~f:(Hash_set.add patterns) ) ;
  patterns

let get_patterns : string list -> string option -> string Hash_set.t =
 fun patterns patterns_file ->
  let patterns_from_positional_args =
    Hash_set.of_list (module String) patterns
  in
  match patterns_file with
  | None ->
      patterns_from_positional_args
  | Some patterns_file ->
      let patterns_from_file = read_patterns patterns_file in
      Hash_set.union patterns_from_positional_args patterns_from_file

let filter :
    nodes_dmp:string -> patterns:string Hash_set.t -> column:int -> unit =
 fun ~nodes_dmp ~patterns ~column ->
  if column > 13 then failwith "there are only 13 columns in the index file!" ;
  (* column is 1-based *)
  let fields = Array.create ~len:column "" in
  let i = column - 1 in
  In_channel.with_file nodes_dmp ~f:(fun ic ->
      In_channel.iter_lines ic ~f:(fun line ->
          Utils.split_dmp_fields line ~into:fields ;
          let field = fields.(i) in
          if Hash_set.mem patterns field then
            Out_channel.output_line Out_channel.stdout line ) )

let run : Cli.Filter_opts.t -> unit =
 fun opts ->
  Logging.set_up_logging opts.log_level ;
  Logs.info (fun m -> m "reading patterns") ;
  let patterns = get_patterns opts.patterns opts.patterns_file in
  Logs.info (fun m -> m "filtering nodes dmp") ;
  filter ~nodes_dmp:opts.nodes_dmp ~patterns ~column:opts.column ;
  ()
