OCaml binding of the [libmongoc](https://mongoc.org/) MongoDB client library for C.

The binding is currently very limited, this is a work in progress.

The library is made available as module `Mongoc`.

C functions name prefixes are turned into modules. C functions name with suffix `_with_opts` are turned into functions with optional parameters. For instance:

* `mongoc_client_get_database` is exposed as `Mongoc.Client.get_database`
* `mongoc_database_get_collection_names_with_opts` is exposed as `Mongoc.Database.get_collection_names`

The library `libbson` is exposed as a submodule `Mongoc.Bson`.
