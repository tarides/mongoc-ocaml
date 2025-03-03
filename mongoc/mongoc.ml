open Ctypes_static

let ( !@ ) = Ctypes.( !@ )

module Bson = Bson

let init = C.Functions.init
let cleanup = C.Functions.cleanup

module Read_prefs = struct
  type t = Types_generated.Read_prefs.t structure ptr

  let t = Types_generated.Read_prefs.t
end

module Uri = struct
  type t = Types_generated.Uri.t structure ptr

  let new_with_error uri : (t, Bson.Error.t) result =
    let error = Ctypes.make Bson.Error.t in
    let uri = Ctypes_std_views.char_ptr_of_string uri in
    let uri = C.Functions.Uri.new_with_error uri (Ctypes.addr error) in
    if Ctypes.is_null uri then Error error else Ok uri

  let destroy (uri : t) = C.Functions.Uri.destroy uri
end

module Cursor = struct
  type t = Types_generated.Cursor.t structure ptr

  let next (cursor : t) : Bson.t option =
    let doc =
      Ctypes.allocate (ptr Bson.t)
        (Ctypes.from_voidp (const Bson.t) Ctypes.null)
    in
    if C.Functions.Cursor.next cursor doc then Some !@(!@doc) else None

  let error (cursor : t) =
    let error = Ctypes.make Bson.Error.t in
    if C.Functions.Cursor.error cursor (Ctypes.addr error) then
      Result.Error error
    else Ok ()

  let destroy (cursor : t) = C.Functions.Cursor.destroy cursor
end

module Collection = struct
  type t = Types_generated.Collection.t structure ptr

  let find_with_opts ?(opts : Bson.t option) ?(read_prefs : Read_prefs.t option)
      (coll : t) (filter : Bson.t) : Cursor.t =
    let filter_ptr = Ctypes.allocate Bson.t filter in
    let opts =
      Option.fold ~some:(Ctypes.allocate Bson.t)
        ~none:(Ctypes.from_voidp Bson.t Ctypes.null)
        opts
    in
    let read_prefs =
      Option.value read_prefs
        ~default:(Ctypes.from_voidp Read_prefs.t Ctypes.null)
    in
    C.Functions.Collection.find_with_opts coll filter_ptr opts read_prefs

  let destroy (coll : t) = C.Functions.Collection.destroy coll
end

module Client = struct
  type t = Types_generated.Client.t structure ptr

  let new_ host : t option =
    let host = Ctypes_std_views.char_ptr_of_string host in
    let client = C.Functions.Client.new_ host in
    if Ctypes.is_null client then None else Some client

  let new_from_uri (uri : Uri.t) : t option =
    let client = C.Functions.Client.new_from_uri uri in
    if Ctypes.is_null client then None else Some client

  let new_from_uri_with_error (uri : Uri.t) : (t, Bson.Error.t) result =
    let error = Ctypes.make Bson.Error.t in
    let client =
      C.Functions.Client.new_from_uri_with_error uri (Ctypes.addr error)
    in
    if Ctypes.is_null client then Error error else Ok client

  let get_collection (client : t) db_name coll_name : Collection.t =
    let open Ctypes_std_views in
    let db_name = char_ptr_of_string db_name in
    let coll_name = char_ptr_of_string coll_name in
    C.Functions.Client.get_collection client db_name coll_name

  let destroy (client : t) = C.Functions.Client.destroy client
end
