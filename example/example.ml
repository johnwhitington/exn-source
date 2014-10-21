let f () =
  List.find (fun x -> x = 1) []

let _ =
  try
    f ()
  with
    e -> raise e

