open! Core

module Taxon = struct
  type t = {taxid: string; rank: string; name: string}

  let to_tsv_string t = [%string "%{t.taxid}\t%{t.rank}\t%{t.name}"]
end

(** [ancestors_of ~starting_taxid ~parent_of] returns a list of all ancestor
    taxonomic IDs from [starting_taxid] to the root of the taxonomy tree.

    The resulting list does NOT contain the original [starting_taxid]. An empty
    list will be returned if the tax ID has no ancestors in the taxonomy.

    - [starting_taxid]: the taxonomy ID to start from
    - [parent_of]: a map from tax ID -> parent tax ID *)
let ancestors_of ~starting_taxid ~parent_of =
  let rec loop ~taxid ~ancestors =
    (* The base node ("1") has itself as its own parent, so need to guard
       against that and stop once you hit the root. *)
    match (taxid, Hashtbl.find parent_of taxid) with
    | "1", _ | _, None ->
        List.rev ancestors
    | _, Some parent ->
        loop ~taxid:parent ~ancestors:(parent :: ancestors)
  in
  loop ~taxid:starting_taxid ~ancestors:[]

let read_nodes_dmp ~nodes_dmp ~parent_of ~rank_of =
  In_channel.with_file nodes_dmp ~f:(fun ic ->
      let fields = Array.create ~len:3 "" in
      In_channel.iter_lines ic ~f:(fun line ->
          Utils.split_dmp_fields line ~into:fields ;
          let taxid = fields.(0) in
          let parent_taxid = fields.(1) in
          let rank = fields.(2) in
          Hashtbl.add_exn parent_of ~key:taxid ~data:parent_taxid ;
          Hashtbl.add_exn rank_of ~key:taxid ~data:rank ) )

let read_names_dmp ~names_dmp ~name_of =
  In_channel.with_file names_dmp ~f:(fun ic ->
      let fields = Array.create ~len:4 "" in
      In_channel.iter_lines ic ~f:(fun line ->
          Utils.split_dmp_fields line ~into:fields ;
          let taxid = fields.(0) in
          let name = fields.(1) in
          let name_class = fields.(3) in
          if String.equal name_class "scientific name" then
            (* If there is more than one scientific name per taxid, this will
               fail. I'm not sure the best way to approach this case, so it's
               fine for now. *)
            Hashtbl.add_exn name_of ~key:taxid ~data:name ) )

let print_taxonomic_paths ~taxids ~parent_of ~rank_of ~name_of =
  print_endline "StartingTaxid\tTaxid\tRank\tName" ;
  let taxon_of_taxid taxid =
    let rank = Hashtbl.find rank_of taxid |> Option.value ~default:"NA" in
    let name = Hashtbl.find name_of taxid |> Option.value ~default:"NA" in
    {Taxon.taxid; rank; name}
  in
  In_channel.with_file taxids ~f:(fun ic ->
      In_channel.iter_lines ic ~f:(fun starting_taxid ->
          match ancestors_of ~starting_taxid ~parent_of with
          | [] ->
              Logs.warn (fun m -> m "no ancestors for %s" starting_taxid) ;
              let taxon =
                taxon_of_taxid starting_taxid |> Taxon.to_tsv_string
              in
              print_endline [%string "%{starting_taxid}\t%{taxon}"]
          | ancestors ->
              let taxids = starting_taxid :: ancestors in
              List.iter taxids ~f:(fun taxid ->
                  let taxon = taxon_of_taxid taxid |> Taxon.to_tsv_string in
                  print_endline [%string "%{starting_taxid}\t%{taxon}"] ) ) )

let run : Cli.Paths_opts.t -> unit =
 fun opts ->
  Logging.set_up_logging opts.log_level ;
  Logs.debug (fun m -> m "%a" Sexp.pp_mach ([%sexp_of: Cli.Paths_opts.t] opts)) ;
  let parent_of = Hashtbl.create (module String) in
  let rank_of = Hashtbl.create (module String) in
  let name_of = Hashtbl.create (module String) in
  Logs.info (fun m -> m "reading nodes dmp") ;
  read_nodes_dmp ~nodes_dmp:opts.nodes_dmp ~parent_of ~rank_of ;
  Logs.info (fun m -> m "reading names dmp") ;
  read_names_dmp ~names_dmp:opts.names_dmp ~name_of ;
  Logs.info (fun m -> m "printing paths") ;
  print_taxonomic_paths ~taxids:opts.taxids ~parent_of ~rank_of ~name_of ;
  Logs.info (fun m -> m "done!") ;
  ()
