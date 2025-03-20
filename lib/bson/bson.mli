module Error : sig
  type t_struct = Types_generated.Error.t Ctypes_static.structure
  type t = t_struct Ctypes_static.ptr

  val t : t_struct Ctypes_static.typ
  val domain : t -> int
  val code : t -> int
  val message : t -> string
end

type t_struct = Types_generated.t Ctypes_static.structure
type t = t_struct Ctypes_static.ptr

module Const : sig
  val some : t_struct -> t
  val none : t
end

val some : t_struct -> t
val none : t
val ptr_of_opt : t opt 
val t : t_struct Ctypes_static.typ
val get_version : unit -> string
val get_major_version : unit -> int
val get_minor_version : unit -> int
val get_micro_version : unit -> int
val new_from_json : ?length:int -> string -> (t, Error.t) result
val as_canonical_extended_json : ?length:int -> t -> string
val as_relaxed_extended_json : ?length:int -> t -> string
val as_json : ?length:int -> t -> string
val destroy : t -> unit
