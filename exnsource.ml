(* Source printing for exception backtraces. Remember: must flush any output. *)
let lines = ref 5

let search_dirs =
  ref ["."]

let add_dir dir =
  search_dirs := dir :: !search_dirs

let _ =
  try
    let tname = Filename.temp_file "ocaml" "exnsource" in
      ignore (Sys.command ("ocamlc -config >" ^ tname));
      let tmp = open_in tname in
        let line = ref "" in
          try
            while true do
              let s = input_line tmp in
                if
                  String.length s >= 18 &&
                  String.sub s 0 18 = "standard_library: "
                then
                  line := s
            done
          with
            End_of_file ->
              close_in tmp;
              Sys.remove tname;
              if !line <> "" then
                add_dir
                  (Filename.dir_sep ^
                   (String.sub !line 19 (String.length !line - 19)))
  with
    _ -> ()

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

let bold, ul, code_end = ("\x1b[1m", "\x1b[4m", "\x1b[0m")

let print_underlined str s e =
  let len = String.length str
  and underlined = ref 0 in
    let pchar x = if x >= 0 && x < len then Printf.eprintf "%c%!" str.[x] in
      for x = 0 to s - 1 do pchar x done;
      Printf.eprintf "%s%!" ul;
      for x = s to e do
        pchar x;
        if x >= 0 && x < len then underlined := !underlined + 1
      done;
      Printf.eprintf "%s%!" code_end;
      for x = e + 1 to len - 1 do pchar x done;
      Printf.eprintf "\n%!";
      !underlined

let print_underlining_prefix str n =
  let len = String.length str in
    let do_ul = min len n in
      Printf.eprintf "%s%!" ul;
      Printf.eprintf "%s%!" (String.sub str 0 do_ul);
      Printf.eprintf "%s%!" code_end;
      Printf.eprintf "%s\n%!" (String.sub str do_ul (len - do_ul));
      do_ul

let print_around_error source line start_char end_char =
  let ch = open_in source
  and read = ref 0
  and to_ul = ref (end_char - start_char + 1) in
    for _ = 1 to line - !lines - 1 do
      if pos_in ch < in_channel_length ch then
        (ignore (input_line ch); read := !read + 1)
    done;
    for _ = 1 to min !lines (line - !read - 1) do
      if pos_in ch < in_channel_length ch then
        Printf.eprintf "%s\n%!" (input_line ch)
    done;
    begin if pos_in ch < in_channel_length ch then
      let line = input_line ch in
        to_ul := !to_ul - print_underlined line start_char end_char;
    end;
    for _ = 1 to !lines do
      if pos_in ch < in_channel_length ch then
        begin
          let line = input_line ch in
            (* Hack. OCaml often produces a location hanging over to the next
            line. Suppress if white space. *)
            if !to_ul = 1 && String.length line > 0 && line.[0] = ' '
              then to_ul := 0;
            if !to_ul > 0
              then to_ul := !to_ul - print_underlining_prefix line !to_ul
              else Printf.eprintf "%s\n%!" line
        end
    done;
    close_in ch

let exn_handler e backtrace =
  Printf.eprintf
    "%sFatal error: exception %s%s\n%!"
    bold (Printexc.to_string e) code_end;
  match Printexc.backtrace_slots backtrace with
    None ->
      Printf.eprintf
        "No backtrace. Compile and link with -g, set OCAMLRUNPARAM=b.\n%!"
  | Some slots ->
      Array.iteri
        (fun i slot ->
           match Printexc.Slot.format i slot with
             None -> ()
           | Some s ->
               Printf.eprintf "%s%s%s\n%!" bold s code_end;
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

