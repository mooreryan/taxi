open! Core

(* Note: there is currently about ~2.6 million nodes (lines) in the nodes.dmp
   file, and ~2.2 million of thise are species level IDs. *)

let get_tax_ids_for_rank target_rank ~in':nodes_dmp =
  In_channel.with_file nodes_dmp ~f:(fun ic ->
      let fields = Array.create ~len:3 "" in
      In_channel.fold_lines ic ~init:[] ~f:(fun tax_ids line ->
          Utils.split_dmp_fields line ~into:fields ;
          let tax_id = fields.(0) in
          let rank = fields.(2) in
          if String.(rank = target_rank) then tax_id :: tax_ids else tax_ids ) )

let sample : 'a list -> size:int -> 'a list =
 fun items ~size -> List.take (List.permute items) size

let run : Opts.Sample_opts.t -> unit =
 fun opts ->
  Logging.set_up_logging opts.log_level ;
  Logs.info (fun m -> m "reading nodes dmp") ;
  let tax_ids = get_tax_ids_for_rank opts.rank ~in':opts.nodes_dmp in
  Logs.info (fun m -> m "sampling nodes") ;
  let sampled_ids = tax_ids |> sample ~size:opts.sample_size in
  Logs.info (fun m -> m "writing data") ;
  Out_channel.output_lines Out_channel.stdout sampled_ids ;
  Logs.info (fun m -> m "done") ;
  ()
