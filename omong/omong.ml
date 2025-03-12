let ( let|| ) (r, err) f =
match r with
| Error s ->
    Printf.fprintf stderr "%s: %s\n" err (Mongoc.Bson.Error.message s);
    exit 1
| Ok x -> f x

let list uri : (string * string) list =
  let () = Mongoc.init () in
  let|| uri = (Mongoc.Uri.new_with_error uri, "Unrecognized URI") in
  let|| client =
    (Mongoc.Client.new_from_uri_with_error uri, "Failed to connect")
  in
  let|| dbs = (Mongoc.Client.get_database_names client, "") in
  let u =
    List.concat_map
      (fun db_name ->
        let db = Mongoc.Client.get_database client db_name in
        let|| colls = (Mongoc.Database.get_collection_names db, "") in
        let v =
          List.map
            (fun coll_name ->
              let coll = Mongoc.Database.get_collection db coll_name in
              Mongoc.Collection.destroy coll;
              (db_name, coll_name))
            colls
        in
        Mongoc.Database.destroy db;
        v)
      dbs
  in
  Mongoc.Client.destroy client;
  Mongoc.Uri.destroy uri;
  Mongoc.cleanup ();
  u

let drop uri db_name coll_name =
  let () = Mongoc.init () in
  let|| uri = (Mongoc.Uri.new_with_error uri, "Unrecognized URI") in
  let|| client =
    (Mongoc.Client.new_from_uri_with_error uri, "Failed to connect")
  in
  let coll = Mongoc.Client.get_collection client db_name coll_name in
  let db = Mongoc.Client.get_database client db_name in
  let|| () = (Mongoc.Collection.drop coll, "collection not found") in
  let|| () = (Mongoc.Database.drop db, "database not found") in
  Mongoc.Database.destroy db;
  Mongoc.Collection.destroy coll;
  Mongoc.Client.destroy client;
  Mongoc.Uri.destroy uri;

  Mongoc.cleanup ()

let find uri db_name coll_name json =
  let () = Mongoc.init () in
  let|| uri = (Mongoc.Uri.new_with_error uri, "Unrecognized URI") in
  let|| client =
    (Mongoc.Client.new_from_uri_with_error uri, "Failed to connect")
  in
  let collection = Mongoc.Client.get_collection client db_name coll_name in
  Printf.printf "BSON query: %s\n" json;
  let|| query = (Mongoc.Bson.new_from_json json, "JSON parsing error") in
  let cursor = Mongoc.Collection.find collection query in
  (try
     while true do
       match Mongoc.Cursor.next cursor with
       | Some doc -> Printf.printf "%s\n" (Mongoc.Bson.as_json doc)
       | None -> raise Exit
     done
   with Exit -> ());
  let|| () = (Mongoc.Cursor.error cursor, "Cursor error") in
  Mongoc.Cursor.destroy cursor;
  Mongoc.Collection.destroy collection;
  Mongoc.Client.destroy client;
  Mongoc.Uri.destroy uri;
  Mongoc.cleanup ()

let json_quote = function
  | ("true" | "false" | "null") as str -> str
  | str when Option.is_some (Int64.of_string_opt str) -> str
  | str when Option.is_some (Float.of_string_opt str) -> str
  | str -> Printf.sprintf {json|"%s"|json} str

let import uri db coll_name csv =
  let cin = Option.fold ~none:stdin ~some:open_in csv in
  let header = input_line cin in
  let keys = String.split_on_char ',' header in
  let () = Mongoc.init () in
  let|| uri = (Mongoc.Uri.new_with_error uri, "Unrecognized URI") in
  let|| client =
    (Mongoc.Client.new_from_uri_with_error uri, "Failed to connect")
  in
  let coll = Mongoc.Client.get_collection client db coll_name in
  (try
     while true do
       let line = input_line cin in
       let values = String.split_on_char ',' line in
       let json =
         List.map2 (fun key value -> Printf.sprintf {json|  "%s": %s|json} key (json_quote value)) keys values
         |> String.concat ",\n" |> Printf.sprintf "{\n%s\n}"
       in
       let|| bson = (Mongoc.Bson.new_from_json json, "JSON parsing error") in
       let|| _ = (Mongoc.Collection.insert_one coll bson, "Insert failure") in
       ()
     done
   with End_of_file -> ());
  let|| filter = (Mongoc.Bson.new_from_json "{}", "Error parse JSON") in
  let|| count =
    (Mongoc.Collection.count_documents coll filter, "Count failure")
  in
  Printf.printf "Collection %s has %Li documents" coll_name count;
  Mongoc.Collection.destroy coll;
  Mongoc.Client.destroy client;
  Mongoc.Uri.destroy uri;
  Mongoc.cleanup ()
