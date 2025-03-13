val init : unit -> unit
val cleanup : unit -> unit

module Bson : sig
  module Error : sig
    type t

    val domain : t -> int
    val code : t -> int
    val message : t -> string
  end

  type t

  val new_from_json : ?len:int -> string -> (t, Error.t) result
  val as_json : ?length:int -> t -> string
end

module Read_prefs : sig
  type t
end

module Uri : sig
  type t

  val new_with_error : string -> (t, Bson.Error.t) result
  val destroy : t -> unit
end

module Cursor : sig
  type t

  val next : t -> Bson.t option
  val error : t -> (unit, Bson.Error.t) result
  val destroy : t -> unit
end

module rec Collection : sig
  type t

  val find : ?opts:Bson.t -> ?read_prefs:Read_prefs.t -> t -> Bson.t -> Cursor.t

  val count_documents :
    ?opts:Bson.t ->
    ?read_prefs:Read_prefs.t ->
    t ->
    Bson.t ->
    (Int64.t, Bson.Error.t) result

  val insert_one : ?opts:Bson.t -> t -> Bson.t -> (Bson.t, Bson.Error.t) result
  val drop : t -> (unit, Bson.Error.t) result
  val destroy : t -> unit
  val of_database : Database.t -> string -> t
end

and Database : sig
  type t

  val get_collection_names :
    ?opts:Bson.t -> t -> (string list, Bson.Error.t) result

  val get_collection : t -> string -> Collection.t
  val drop : t -> (unit, Bson.Error.t) result
  val destroy : t -> unit
  val of_client : Client.t -> string -> t
end

and Client : sig
  type t

  val new_ : string -> t option
  val new_from_uri : Uri.t -> t option
  val new_from_uri_with_error : Uri.t -> (t, Bson.Error.t) result

  val get_database_names :
    ?opts:Bson.t -> t -> (string list, Bson.Error.t) result

  val get_database : t -> string -> Database.t
  val get_collection : t -> string -> string -> Collection.t
  val destroy : t -> unit
end
