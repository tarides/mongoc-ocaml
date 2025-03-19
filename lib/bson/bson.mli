module Error : sig
  type t = Types_generated.Error.t Ctypes_static.structure

  val t : t Ctypes_static.typ
  val domain : t -> int
  val code : t -> int
  val message : t -> string
end

type t = Types_generated.t Ctypes_static.structure

module Const : sig
  val some : t -> t Ctypes_static.ptr
  val none : t Ctypes_static.ptr
end

val some : t -> t Ctypes_static.ptr
val none : t Ctypes_static.ptr
val t : t Ctypes_static.typ
val get_version : unit -> string
val get_major_version : unit -> int
val get_minor_version : unit -> int
val get_micro_version : unit -> int
val new_from_json : ?length:int -> string -> (t, Error.t) result
val as_canonical_extended_json : ?length:int -> t -> string
val as_relaxed_extended_json : ?length:int -> t -> string
val as_json : ?length:int -> t -> string
