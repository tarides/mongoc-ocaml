open Ctypes

  let carray_to_string (arr : char CArray.t) : string =
    arr |> CArray.to_list |> List.to_seq |> String.of_seq

let () =
  let () = Mongoc.C.Functions.init () in
  let host = Ctypes_std_views.char_ptr_of_string "mongodb://127.0.0.1:27017" in
  if is_null host then begin
    Printf.fprintf stderr "Failed to connect to MongoDB\n";
    exit 1;
  end;
  let client = Mongoc.C.Functions.Client.new_ host in
  let db_name = Ctypes_std_views.char_ptr_of_string "bitcoin" in
  let collection_name = Ctypes_std_views.char_ptr_of_string "price_2017_2023" in
  let collection = Mongoc.C.Functions.Client.get_collection client db_name collection_name in
  let json = Ctypes_std_views.char_ptr_of_string "{ \"timestamp\" : { \"$gt\" : \"2022-07-28 10:00:00\", \"$lte\" : \"2022-07-28 10:10:00\" } }" in
  Printf.printf "BSON query: %s\n" (Ctypes_std_views.string_of_char_ptr json);
  let json = coerce (ptr char) (ptr (const uint8_t)) json in
  let error = make Bson.Types_generated.Error.t in
  let query = Bson.C.Functions.new_from_json json PosixTypes.Ssize.minus_one (addr error) in
  if is_null query then begin
    let message = getf error Bson.Types_generated.Error.message in
    Printf.fprintf stderr "JSON parsing Error: %s\n" (carray_to_string message);
    exit 1;
  end;
  let null_query = from_voidp Bson.Types_generated.t null in
  let null_read_prefs = from_voidp Mongoc.Types_generated.Read_prefs.t null in
  let cursor = Mongoc.C.Functions.Collection.find_with_opts collection query null_query null_read_prefs in
  let doc = allocate (ptr Bson.Types_generated.t) (from_voidp (const Bson.Types_generated.t) null) in
  Printf.printf("Bitcoin prices on July 28, 2022, at 10 a.m. during 10 minutes:\n");
  while Mongoc.C.Functions.Cursor.next cursor doc do
    let str = Bson.C.Functions.as_json !@doc (from_voidp size_t null) in
    Printf.printf "%s\n" (Ctypes_std_views.string_of_char_ptr str);
    Bson.C.Functions.free (to_voidp str);
  done;
  if Mongoc.C.Functions.Cursor.error cursor (Ctypes.addr error) then begin
    let message = getf error Bson.Types_generated.Error.message in
    Printf.fprintf stderr "Cursor Error: %s\n" (carray_to_string message);
    exit 1
  end;
  Mongoc.C.Functions.Cursor.destroy cursor;
  Mongoc.C.Functions.Collection.destroy collection;
  Mongoc.C.Functions.Client.destroy client;
  Mongoc.C.Functions.cleanup ()
