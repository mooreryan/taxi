open! Core

(* Split dmp file line into fields using the given array for storage.

   This is significantly faster than using [Re.split], and is checked against
   [Re.split] in the property tests. *)
let split_dmp_fields : string -> into:string array -> unit =
 fun s ~into:fields ->
  let input_string_length = String.length s in
  (* Weird edge cases where the line has no fields *)
  if String.equal s "\t|" || String.equal s "\t|\n" then ()
  else begin
    if input_string_length < 3 then failwith "Invalid line -- too short" ;
    let max_fields = Array.length fields in
    let rec loop i last_i field_count =
      if field_count >= max_fields then ()
      else if i > input_string_length - 3 then ()
      else
        match (s.[i], s.[i + 1], s.[i + 2]) with
        | '\t', '|', '\t' ->
            (* Normal field delimiter *)
            let field = String.sub s ~pos:last_i ~len:(i - last_i) in
            fields.(field_count) <- field ;
            let next_start = i + 3 in
            loop next_start next_start (field_count + 1)
        | '\t', '|', '\n' ->
            (* Normal end delimiter *)
            if i + 3 = input_string_length then
              let field = String.sub s ~pos:last_i ~len:(i - last_i) in
              fields.(field_count) <- field
            else
              failwithf
                "Invalid line -- should only see the [tab bar nl] end \
                 delimiter at the end of the line: %s"
                s ()
        | _, '\t', '|' ->
            (* Possibly the chopped end delimiter that can happen if you use
               [In_channel.iter_lines] or another function that chops newlines.
               We need to check if that is the case . *)
            if i + 3 = input_string_length then
              let field = String.sub s ~pos:last_i ~len:(i + 1 - last_i) in
              fields.(field_count) <- field
            else loop (i + 1) last_i field_count
        | _, _, _ ->
            loop (i + 1) last_i field_count
    in
    loop 0 0 0
  end
