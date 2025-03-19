module Error : sig
  type t = Types_generated.Error.t Ctypes_static.structure

  val t : t Ctypes_static.typ
  val domain : t -> int
  val code : t -> int
  val message : t -> string
end

type t = Types_generated.t Ctypes_static.structure

val t : t Ctypes_static.typ
val new_from_json : ?len:int -> string -> (t, Error.t) result
val as_json : ?length:int -> t -> string
