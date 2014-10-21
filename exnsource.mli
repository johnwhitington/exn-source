(** Controls the exnsource exception printer *)

(** Number of lines to print either side of the offending one. *)
val lines : int ref

(** Add a directory to be searched. The default is the current working
directory, and the OCaml standard library. The search order is unspecified. *)
val add_dir : string -> unit

(** Remove a directory from the search list. *)
val remove_dir : string -> unit

