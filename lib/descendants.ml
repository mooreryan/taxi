open! Core

(* This is significantly faster than using [Re.split].

   (It is checked against [Re.split] in the property tests.) *)
let split_fields : string -> child_id:string ref -> id:string ref -> unit =
 fun s ~child_id ~id ->
  let len = String.length s in
  let rec loop i l field_count =
    if i >= len && field_count <> 2 then
      (* Technically, the only way we wouldn't finish out both fields is if the
         file was bad, so just fail here. *)
      failwith "we got the wrong number of fields; check your input file!"
    else if i >= len || field_count >= 2 then ()
    else
      match s.[i] with
      | '\t' ->
          (* We need to check and see if we are in a delimiter or not. But, we
             also cannot check that unless we know for sure we won't go out of
             bounds. *)
          if i >= len - 2 then
            (* We know for sure we are not in a delimiter, because there aren't
               enough characters for a delimiter. *)
            loop (i + 1) l field_count
          else if
            (* The delimiter is ["\t|\t"], so check if we see it. *)
            Char.equal s.[i + 1] '|' && Char.equal s.[i + 2] '\t'
          then (
            (* We are in a delimiter! *)
            let field = String.sub s ~pos:l ~len:(i - l) in
            if field_count = 0 then child_id := field
            else if field_count = 1 then id := field
            else assert false ;
            let next_start = i + 3 in
            loop next_start next_start (field_count + 1) ;
            () )
          else (* We are not in a delimiter! *)
            loop (i + 1) l field_count
      | _ ->
          loop (i + 1) l field_count
  in
  loop 0 0 0

(** [read_nodes_dmp file_name] reads the nodes.dmp file into a Hashtbl of -> ID
    to children IDs. *)
let read_nodes_dmp : string -> (string, string list) Hashtbl.t =
 fun nodes_dmp ->
  let child_id = ref "" in
  let id = ref "" in
  let children_of = Hashtbl.create (module String) in
  In_channel.with_file nodes_dmp ~f:(fun ic ->
      In_channel.iter_lines ic ~f:(fun line ->
          split_fields line ~child_id ~id ;
          Hashtbl.update children_of !id ~f:(function
            | None ->
                [!child_id]
            | Some children ->
                !child_id :: children ) ) ) ;
  children_of

(** [read_query_ids] reads the query ID file into a list of query IDs. Assumes
    that there is a single ID per line. *)
let read_query_ids : string -> string list =
 fun ids -> In_channel.read_lines ids

(** [descendants children_of id] gets all the descendants of [id], given the
    parent-child relationships defined in [children_of]. *)
let descendants : (string, string list) Hashtbl.t -> string -> unit =
 fun children_of start_id ->
  let ids = Stack.of_list [start_id] in
  let rec loop () =
    match Stack.pop ids with
    | None ->
        ()
    | Some id -> (
      match Hashtbl.find children_of id with
      | None ->
          loop ()
      | Some children ->
          List.iter children ~f:(fun child ->
              Stack.push ids child ;
              print_endline [%string "%{start_id}\t%{id}\t%{child}"] ) ;
          loop () )
  in
  loop ()

let descendants' : (string, string list) Hashtbl.t -> string list -> unit =
 fun children_of start_ids -> List.iter start_ids ~f:(descendants children_of)

let run : Opts.Descendants_opts.t -> unit =
 fun opts ->
  Logging.set_up_logging opts.log_level ;
  Logs.debug (fun m ->
      m "%a" Sexp.pp_mach ([%sexp_of: Opts.Descendants_opts.t] opts) ) ;
  Logs.info (fun m -> m "reading nodes dmp") ;
  let children_of = read_nodes_dmp opts.nodes_dmp in
  Logs.info (fun m -> m "reading query ids") ;
  let ids = read_query_ids opts.ids in
  Logs.info (fun m -> m "getting descendants") ;
  descendants' children_of ids ;
  Logs.info (fun m -> m "done") ;
  ()