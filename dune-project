(lang dune 3.16)

(using ctypes 0.3)

(name mongoc)

(generate_opam_files true)

(package
 (name mongoc)
 (synopsis "OCaml binding of the libmongoc library")
 (description "OCaml binding of the MongoDB client library for C, libmongoc")
 (maintainers "Cuihtlauac ALVARADO")
 (authors "Cuihtlauac ALVARADO")
 (source
  (github tarides/mongoc-ocaml))
 (license ISC)
 (depends
  (ocaml
   (>= 4.14.0))
  (ocamlformat :with-dev-setup)
  (cmdliner
   (and
    (>= 1.3.0)
    :with-test))
  (ctypes
   (>= 0.23.0))
  (conf-pkg-config :build)))
