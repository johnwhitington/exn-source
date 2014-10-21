let _ =
  Exnsource.add_dir "/usr/local/lib/ocaml";
  Exnsource.lines := 5

let f () =
  List.find (fun x -> x = 1) []

let _ =
  try
    f ()
  with
    e -> raise e

