open! Core

(* This is significantly faster than using [Re.split].

   (It is checked against [Re.split] in the property tests.) *)
let split_dmp_fields : string -> into:string array -> unit =
 fun s ~into:fields ->
  let input_string_length = String.length s in
  let max_fields = Array.length fields in
  let rec loop i l field_count =
    if i >= input_string_length || field_count >= max_fields then ()
    else
      match s.[i] with
      | '\t' ->
          (* We need to check and see if we are in a delimiter or not. But, we
             also cannot check that unless we know for sure we won't go out of
             bounds. *)
          if i >= input_string_length - 2 then
            (* We know for sure we are not in a delimiter, because there aren't
               enough characters for a delimiter. *)
            loop (i + 1) l field_count
          else if
            (* The delimiter is ["\t|\t"], so check if we see it. *)
            Char.equal s.[i + 1] '|' && Char.equal s.[i + 2] '\t'
          then (
            (* We are in a delimiter! *)
            let field = String.sub s ~pos:l ~len:(i - l) in
            fields.(field_count) <- field ;
            let next_start = i + 3 in
            loop next_start next_start (field_count + 1) ;
            () )
          else (* We are not in a delimiter! *)
            loop (i + 1) l field_count
      | _ ->
          loop (i + 1) l field_count
  in
  loop 0 0 0
