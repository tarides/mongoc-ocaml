open Cmdliner

let default_uri = "mongodb://localhost:27017"

let list uri =
  let print (db, coll) = Printf.printf "%s.%s\n" db coll in
  uri
  |> Omong.list
  |> List.iter print

let drop uri db coll =
  Omong.drop uri db coll

let import uri db coll csv =
  Omong.import uri db coll csv

let uri =
  let doc, docv = "MongoDB $(docv)", "URI" in
  Arg.(value @@ opt string default_uri @@ info ~docv ~doc [ "u"; "uri" ])

let list_cmd =
  let doc = "List database and collections" in
  let info = Cmd.info "list" ~doc in
  Cmd.v info Term.(const list $ uri)

let database =
  let doc, docv = "MongoDB database name", "DB" in
  Arg.(value @@ pos 0 string "" @@ info [] ~doc ~docv)

let collection =
  let doc, docv = "MongoDB collection name", "COLL" in
  Arg.(value @@ pos 1 string "" @@ info [] ~doc ~docv)

let drop_cmd =
  let doc = "Drop database or collection" in
  let info = Cmd.info "drop" ~doc in
  Cmd.v info Term.(const drop $ uri $ database $ collection)

let csv =
  let doc, docv = "CSV data", "CSV" in
  Arg.(value @@ opt (some string) None @@ info [ "csv" ] ~doc ~docv)

let import_cmd =
  let doc = "Import CSV into collection" in
  let info = Cmd.info "import" ~doc in
  Cmd.v info Term.(const import $ uri $ database $ collection $ csv)

let omong_cmd =
  let doc = "MongoDB client" in
  let info = Cmd.info ~doc "omong" in
  Cmd.group info [list_cmd; drop_cmd; import_cmd]

let () = omong_cmd |> Cmd.eval |> exit
