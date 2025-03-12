let () =
  let ( let|| ) (r, err) f =
    match r with
    | Error s ->
        Printf.fprintf stderr "%s: %s\n" err (Mongoc.Bson.Error.message s);
        exit 1
    | Ok x -> f x
  in
  let () = Mongoc.init () in
  let|| uri =
    (Mongoc.Uri.new_with_error "mongodb://127.0.0.1:27017", "Unrecognized URI")
  in
  let|| client =
    (Mongoc.Client.new_from_uri_with_error uri, "Failed to connect")
  in
  let collection =
    Mongoc.Client.get_collection client Sys.argv.(1) Sys.argv.(2)
  in
  let cin = open_in Sys.argv.(3) in
  let json = In_channel.input_all cin in
  close_in cin;
  Printf.printf "BSON query: %s" json;
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
