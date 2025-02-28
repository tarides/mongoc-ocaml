open Ctypes

let init = C.Functions.init
let cleanup = C.Functions.cleanup

module Client = struct
  type t = Types_generated.Collection.t Ctypes_static.structure
  let new_ host =
    let host = Ctypes_std_views.char_ptr_of_string host in
    let client = C.Functions.Client.new_ host in
    Result.(if is_null client then Error "Failed to connect to MongoDB" else Ok client)

  let get_collection client db_name coll_name =
    let open Ctypes_std_views in
    let db_name = char_ptr_of_string db_name in
    let coll_name = char_ptr_of_string coll_name in
    C.Functions.Client.get_collection client db_name coll_name

  let destroy = C.Functions.Client.destroy
end

module Collection = struct
  let find_with_opts ?opts ?read_prefs coll filter =
    let opts = Option.value opts ~default:(from_voidp Bson.t null) in
    let read_prefs = Option.value read_prefs ~default:(from_voidp Types_generated.Read_prefs.t null) in
    C.Functions.Collection.find_with_opts coll filter opts read_prefs
  let destroy = C.Functions.Collection.destroy
end

let carray_to_string (arr : char CArray.t) : string =
  arr |> CArray.to_list |> List.to_seq |> String.of_seq

module Cursor = struct
  let next cursor =
    let doc = allocate (ptr Bson.t) (from_voidp (const Bson.t) null) in
    if C.Functions.Cursor.next cursor doc then
      Some !@doc
    else None

  let error cursor =
    let error = make Bson.Error.t in
    if C.Functions.Cursor.error cursor (addr error) then
      let message = Bson.Error.message error in
      Result.Error ("Cursor Error:" ^ message)
    else Ok ()
  let destroy = C.Functions.Cursor.destroy
end
