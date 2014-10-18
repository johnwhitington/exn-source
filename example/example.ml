let _ =
  Exnsource.add_dir "/Users/john/trunk/stdlib"
  
let f () =
  List.find (fun x -> x = 1) []

let _ =
  try
    f ()
  with
    e -> raise e

