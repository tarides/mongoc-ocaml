(lang dune 3.16)
(using ctypes 0.3)
(name ocaml-mongoc)
(generate_opam_files true)
(package
 (name ocaml-mongoc)
 (synopsis "OCaml binding of the libmongoc library")
 (description "OCaml binding of the MongoDB client library for C, libmongoc")
 (depends
  (dune :build)
  (ocamlformat :build)
  cmdliner
  ctypes))
