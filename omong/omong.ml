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
      let|| db = wrap Mongoc.Database.(from_client client, destroy, db_name) in
      let|| colls =
        Mongoc.Database.(get_collection_names ?opts:None, ignore, db)
      in
      List.map
        (fun coll_name ->
          let|| _ =
            wrap Mongoc.Collection.(from_database db, destroy, coll_name)
          in
          (db_name, coll_name))
        colls)
    dbs

let drop uri db_name coll_name =
  let|| () = wrap Mongoc.(init, cleanup, ()) in
  let|| uri = Mongoc.Uri.(new_with_error, destroy, uri) in
  let|| client = Mongoc.Client.(new_from_uri_with_error, destroy, uri) in
  let|| db = wrap Mongoc.Database.(from_client client, destroy, db_name) in
  let|| coll = wrap Mongoc.Collection.(from_database db, destroy, coll_name) in
  let|| () = Mongoc.Collection.(drop, ignore, coll) in
  let|| () = Mongoc.Database.(drop, ignore, db) in
  ()

let cursor_step cursor =
  match Mongoc.Cursor.next cursor with
  | Some doc -> Some (doc, cursor)
  | None -> None

let find uri db_name coll_name json =
  let|| () = wrap Mongoc.(init, cleanup, ()) in
  let|| uri = Mongoc.Uri.(new_with_error, destroy, uri) in
  let|| client = Mongoc.Client.(new_from_uri_with_error, destroy, uri) in
  let|| db = wrap Mongoc.Database.(from_client client, destroy, db_name) in
  let|| coll = wrap Mongoc.Collection.(from_database db, destroy, coll_name) in
  Printf.printf "BSON query: %s\n" json;
  let|| query = Mongoc.Bson.(new_from_json ?len:None, ignore, json) in
  let|| cursor = wrap Mongoc.(Collection.find coll, Cursor.destroy, query) in
  Seq.unfold cursor_step cursor
  |> Seq.map Mongoc.Bson.as_json
  |> Seq.iter (Printf.printf "%s\n");
  let|| () = Mongoc.Cursor.(error, ignore, cursor) in
  ()

let json_quote = function
  | ("true" | "false" | "null") as str -> str
  | str when Option.is_some (Int64.of_string_opt str) -> str
  | str when Option.is_some (Float.of_string_opt str) -> str
  | str -> Printf.sprintf {json|"%s"|json} str

let json_field key value =
  Printf.sprintf {json|  "%s": %s|json} key (json_quote value)

let json_object keys values =
  List.map2 json_field keys values
  |> String.concat ",\n" |> Printf.sprintf "{\n%s\n}"

let ( let< ) file f =
  match file with
  | Some file ->
      let cin = open_in file in
      let finally () = close_in cin in
      Fun.protect ~finally (fun () -> f cin)
  | None -> f stdin

let input_line_step cin =
  try Some (input_line cin, cin) with End_of_file -> None

let import uri db_name coll_name csv =
  let< cin = csv in
  let header = input_line cin in
  let keys = String.split_on_char ',' header in
  let|| () = wrap Mongoc.(init, cleanup, ()) in
  let|| uri = Mongoc.Uri.(new_with_error, destroy, uri) in
  let|| client = Mongoc.Client.(new_from_uri_with_error, destroy, uri) in
  let|| db = wrap Mongoc.Database.(from_client client, destroy, db_name) in
  let|| coll = wrap Mongoc.Collection.(from_database db, destroy, coll_name) in
  Seq.unfold input_line_step cin
  |> Seq.map (String.split_on_char ',')
  |> Seq.map (json_object keys)
  |> Seq.iter (fun json ->
         let|| bson = Mongoc.Bson.(new_from_json ?len:None, ignore, json) in
         let|| _ = Mongoc.Collection.(insert_one coll, ignore, bson) in
         ());
  let|| filter = Mongoc.Bson.(new_from_json ?len:None, ignore, "{}") in
  let|| count = Mongoc.Collection.(count_documents coll, ignore, filter) in
  Printf.printf "Collection %s has %Li documents" coll_name count
