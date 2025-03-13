let ( let|| ) (f, h, x) g =
  match f x with
  | Error err ->
      Printf.fprintf stderr "%s\n" (Mongoc.Bson.Error.message err);
      exit 1
  | Ok x ->
      let y = g x in
      h x;
      y

let result_app f x =
  match (f, x) with
  | _, Error x -> Error x
  | Error f, _ -> Error f
  | Ok f, Ok x -> Ok (f x)

let wrap (f, g, x) = (result_app (Ok f), g, Ok x)

let list uri : (string * string) list =
  let|| () = wrap Mongoc.(init, cleanup, ()) in
  let|| uri = Mongoc.Uri.(new_with_error, destroy, uri) in
  let|| client = Mongoc.Client.(new_from_uri_with_error, destroy, uri) in
  let|| dbs = Mongoc.Client.(get_database_names ?opts:None, ignore, client) in
  List.concat_map
    (fun db_name ->
      let db = Mongoc.Client.get_database client db_name in
      let|| colls =
        Mongoc.Database.(get_collection_names ?opts:None, ignore, db)
      in
      List.map
        (fun coll_name ->
          let|| _ =
            Mongoc.
              ( result_app (Ok (Database.get_collection db)),
                Collection.destroy,
                Ok coll_name )
          in
          (db_name, coll_name))
        colls)
    dbs

let drop uri db_name coll_name =
  let|| () = wrap Mongoc.(init, cleanup, ()) in
  let|| uri = Mongoc.Uri.(new_with_error, destroy, uri) in
  let|| client = Mongoc.Client.(new_from_uri_with_error, destroy, uri) in
  let|| db = wrap Mongoc.Database.(of_client client, destroy, db_name) in
  let|| coll = wrap Mongoc.Collection.(of_database db, destroy, coll_name) in
  let|| () = Mongoc.Collection.(drop, ignore, coll) in
  let|| () = Mongoc.Database.(drop, ignore, db) in
  ()

let find uri db_name coll_name json =
  let|| () = wrap Mongoc.(init, cleanup, ()) in
  let|| uri = Mongoc.Uri.(new_with_error, destroy, uri) in
  let|| client = Mongoc.Client.(new_from_uri_with_error, destroy, uri) in
  let|| db = wrap Mongoc.Database.(of_client client, destroy, db_name) in
  let|| coll = wrap Mongoc.Collection.(of_database db, destroy, coll_name) in
  Printf.printf "BSON query: %s\n" json;
  let|| query = Mongoc.Bson.(new_from_json ?len:None, ignore, json) in
  let|| cursor = wrap Mongoc.(Collection.find coll, Cursor.destroy, query) in
  (try
     while true do
       match Mongoc.Cursor.next cursor with
       | Some doc -> Printf.printf "%s\n" (Mongoc.Bson.as_json doc)
       | None -> raise Exit
     done
   with Exit -> ());
  let|| () = Mongoc.Cursor.(error, ignore, cursor) in
  ()

let json_quote = function
  | ("true" | "false" | "null") as str -> str
  | str when Option.is_some (Int64.of_string_opt str) -> str
  | str when Option.is_some (Float.of_string_opt str) -> str
  | str -> Printf.sprintf {json|"%s"|json} str

let import uri db_name coll_name csv =
  let cin = Option.fold ~none:stdin ~some:open_in csv in
  let header = input_line cin in
  let keys = String.split_on_char ',' header in
  let|| () = wrap Mongoc.(init, cleanup, ()) in
  let|| uri = Mongoc.Uri.(new_with_error, destroy, uri) in
  let|| client = Mongoc.Client.(new_from_uri_with_error, destroy, uri) in
  let|| db = wrap Mongoc.Database.(of_client client, destroy, db_name) in
  let|| coll = wrap Mongoc.Collection.(of_database db, destroy, coll_name) in
  (try
     while true do
       let line = input_line cin in
       let values = String.split_on_char ',' line in
       let json =
         List.map2
           (fun key value ->
             Printf.sprintf {json|  "%s": %s|json} key (json_quote value))
           keys values
         |> String.concat ",\n" |> Printf.sprintf "{\n%s\n}"
       in
       let|| bson = Mongoc.Bson.(new_from_json ?len:None, ignore, json) in
       let|| _ = Mongoc.Collection.(insert_one coll, ignore, bson) in
       ()
     done
   with End_of_file -> ());
  let|| filter = Mongoc.Bson.(new_from_json ?len:None, ignore, "{}") in
  let|| count = Mongoc.Collection.(count_documents coll, ignore, filter) in
  Printf.printf "Collection %s has %Li documents" coll_name count
