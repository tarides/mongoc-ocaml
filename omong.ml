open Cmdliner

let default_uri = "mongodb://localhost:27017"

let list uri =
  let print (db, coll) = Printf.printf "%s.%s\n" db coll in
  uri |> Omong.list |> List.iter print

let drop uri db coll = Omong.drop uri db coll
let import uri db coll csv = Omong.import uri db coll csv

let find uri db coll json =
  let json = match json with
    | None -> "{}"
    | Some filename -> begin
      let cin = open_in filename in
      let json = In_channel.input_all cin in
      close_in cin;
    json
    end in
  Omong.find uri db coll json

let uri =
  let doc, docv = ("MongoDB $(docv)", "URI") in
  Arg.(value @@ opt string default_uri @@ info ~docv ~doc [ "uri"; "u" ])

let list_cmd =
  let doc = "List database and collections" in
  let info = Cmd.info "list" ~doc in
  Cmd.v info Term.(const list $ uri)

let database =
  let doc, docv = ("MongoDB database name", "DB") in
  Arg.(value @@ pos 0 string "" @@ info [] ~doc ~docv)

let collection =
  let doc, docv = ("MongoDB collection name", "COLL") in
  Arg.(value @@ pos 1 string "" @@ info [] ~doc ~docv)

let drop_cmd =
  let doc = "Drop database or collection" in
  let info = Cmd.info "drop" ~doc in
  Cmd.v info Term.(const drop $ uri $ database $ collection)

let json =
  let doc, docv = ("MongoDB JSON query", "JSON") in
  Arg.(value @@ pos 2 (some string) None @@ info [] ~doc ~docv)

let find_cmd =
  let doc = "Query database" in
  let info = Cmd.info "find" ~doc in
  Cmd.v info Term.(const find $ uri $ database $ collection $ json)

let csv =
  let doc, docv = ("CSV data", "CSV") in
  Arg.(value @@ pos 2 (some string) None @@ info [] ~doc ~docv)

let import_cmd =
  let doc = "Import CSV into collection" in
  let info = Cmd.info "import" ~doc in
  Cmd.v info Term.(const import $ uri $ database $ collection $ csv)

let omong_cmd =
  let doc = "MongoDB client" in
  let info = Cmd.info ~doc "omong" in
  Cmd.group info [ list_cmd; drop_cmd; find_cmd; import_cmd ]

let () = omong_cmd |> Cmd.eval |> exit
