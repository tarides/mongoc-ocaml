let () =
  let ( let|| ) r f = match r with
    | Error s -> begin Printf.fprintf stderr "%s\n" s; exit 1 end
    | Ok x -> f x in
  let () = Mongoc.init () in
  let|| client = Mongoc.Client.new_ "mongodb://127.0.0.1:27017" in
  let collection = Mongoc.Client.get_collection client "bitcoin" "price_2017_2023" in
  let json = {json|{ "timestamp" : { "$gt" : "2022-07-28 10:00:00", "$lte" : "2022-07-28 10:10:00" } }|json} in
  Printf.printf "BSON query: %s\n" json;
  let|| query = Bson.new_from_json json in
  let cursor = Mongoc.Collection.find_with_opts collection query in
  Printf.printf("Bitcoin prices on July 28, 2022, at 10 a.m. during 10 minutes:\n");
  try while true do
    match Mongoc.Cursor.next cursor with
    | Some doc -> Printf.printf "%s\n" (Bson.as_json doc)
    | None -> raise Exit
  done with Exit -> ();
  let|| () = Mongoc.Cursor.error cursor in
  Mongoc.Cursor.destroy cursor;
  Mongoc.Collection.destroy collection;
  Mongoc.Client.destroy client;
  Mongoc.cleanup ()
