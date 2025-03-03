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
    Mongoc.Client.get_collection client "bitcoin" "price_2017_2023"
  in
  let json =
    {json|{ "timestamp" : { "$gt" : "2022-07-28 10:00:00", "$lte" : "2022-07-28 10:10:00" } }|json}
  in
  Printf.printf "BSON query: %s\n" json;
  let|| query = (Mongoc.Bson.new_from_json json, "JSON parsing error") in
  let cursor = Mongoc.Collection.find_with_opts collection query in
  Printf.printf
    "Bitcoin prices on July 28, 2022, at 10 a.m. during 10 minutes:\n";
  try
    while true do
      match Mongoc.Cursor.next cursor with
      | Some doc -> Printf.printf "%s\n" (Mongoc.Bson.as_json doc)
      | None -> raise Exit
    done
  with Exit ->
    ();
    let|| () = (Mongoc.Cursor.error cursor, "Cursor error") in
    Mongoc.Cursor.destroy cursor;
    Mongoc.Collection.destroy collection;
    Mongoc.Client.destroy client;
    Mongoc.Uri.destroy uri;
    Mongoc.cleanup ()
