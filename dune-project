(lang dune 3.16)
(using ctypes 0.3)
(generate_opam_files true)
(package
 (name ocaml-libmongoc)
 (synopsis "OCaml binding of the libmongoc library")
 (description "OCaml binding of the MongoDB client library for C, libmongoc")
 (depends
  (dune :build)
  (ocamlformat :build)
  ctypes))
