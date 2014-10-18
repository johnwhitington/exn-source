(* Source printing for exception backtraces. *)

(* Remember: we cannot use exceptions inside the exception backtrace handler!
Including things like End_of_file! Also, must flush any output. *)

let lines = ref 5

let search_dirs =
  ref ["."]

let add_dir dir =
  search_dirs := dir :: !search_dirs

let rec remove_item prev dir dirs =
  match dirs with
    [] -> prev
  | h::t when h = dir -> remove_item prev dir t
  | h::t -> remove_item (h :: prev) dir t

let remove_dir dir =
  search_dirs := remove_item [] dir !search_dirs

let locate_source_file leafname =
  let first_found = ref None in
    List.iter
      (fun dir ->
         let full = Filename.concat dir leafname in
           if Sys.file_exists full && !first_found = None
             then first_found := Some full)
      !search_dirs;
    !first_found

let print_around_error source line start_char end_char =
  let ch = open_in source in
    for _ = 0 to line - !lines do
      if pos_in ch < in_channel_length ch then
        ignore (input_line ch)
    done;
    for _ = 0 to !lines * 2 + 1 do
      if pos_in ch < in_channel_length ch then
        Printf.printf "%s\n%!" (input_line ch)
    done;
    close_in ch

let exn_handler e backtrace =
  match Printexc.backtrace_slots backtrace with
    None ->
      Printf.printf "No backtrace found.\n%!"
  | Some slots ->
      Array.iteri
        (fun i slot ->
           match Printexc.Slot.format i slot with
             None -> ()
           | Some s ->
               Printf.printf "***%s***\n%!" s;
               match Printexc.Slot.location slot with
                 None -> ()
               | Some loc ->
                   match locate_source_file loc.Printexc.filename with
                     None -> ()
                   | Some source ->
                       print_around_error
                         source
                         loc.Printexc.line_number
                         loc.Printexc.start_char
                         loc.Printexc.end_char)
        slots

let _ =
  Printexc.set_uncaught_exception_handler exn_handler

