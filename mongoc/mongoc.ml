open Ctypes

let init = C.Functions.init
let cleanup = C.Functions.cleanup

module Read_prefs = struct
  type t = Types_generated.Read_prefs.t structure Ctypes_static.ptr
end

module Cursor = struct
  type t = Types_generated.Cursor.t structure Ctypes_static.ptr

  let next (cursor : t) : Bson.t_ptr option =
    let doc = allocate Bson.ptr_t (from_voidp Bson.const_t null) in
    if C.Functions.Cursor.next cursor doc then Some !@doc else None

  let error (cursor : t) =
    let error = make Bson.Error.t in
    if C.Functions.Cursor.error cursor (addr error) then
      let message = Bson.Error.message error in
      Result.Error ("Cursor Error:" ^ message)
    else Ok ()
  let destroy = C.Functions.Cursor.destroy
end

module Collection = struct
  type t = Types_generated.Collection.t structure Ctypes_static.ptr

  let find_with_opts ?(opts : Bson.t_ptr option) ?(read_prefs : Read_prefs.t option) (coll : t) (filter : Bson.t_ptr) : Cursor.t =
    let opts = Option.value opts ~default:(from_voidp Bson.t null) in
    let read_prefs = Option.value read_prefs ~default:(from_voidp Types_generated.Read_prefs.t null) in
    C.Functions.Collection.find_with_opts coll filter opts read_prefs
  let destroy = C.Functions.Collection.destroy
end

module Client = struct
  type t = Types_generated.Client.t structure Ctypes_static.ptr

  let new_ host : (t, string) result =
    let host = Ctypes_std_views.char_ptr_of_string host in
    let client = C.Functions.Client.new_ host in
    Result.(if is_null client then Error "Failed to connect to MongoDB" else Ok client)

  let get_collection (client : t) db_name coll_name : Collection.t =
    let open Ctypes_std_views in
    let db_name = char_ptr_of_string db_name in
    let coll_name = char_ptr_of_string coll_name in
    C.Functions.Client.get_collection client db_name coll_name

  let destroy = C.Functions.Client.destroy
end


