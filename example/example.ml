let _ =
  Exnsource.add_dir "/Users/john/trunk/stdlib"; (* <--- Add yours here! *)
  Exnsource.lines := 5 (* Number of lines each side *)
  
let f () =
  List.find (fun x -> x = 1) []

let _ =
  try
    f ()
  with
    e -> raise e

