module Functions (F : Ctypes.FOREIGN) = struct
  open Ctypes_static
  open F

  let init = foreign "mongoc_init" (void @-> returning void)
  let cleanup = foreign "mongoc_cleanup" (void @-> returning void)

  let get_version = foreign "mongoc_get_version" (void @-> returning (ptr (const char)))

  let get_major_version = foreign "mongoc_get_major_version" (void @-> returning int)

  let get_minor_version = foreign "mongoc_get_minor_version" (void @-> returning int)

  let get_micro_version = foreign "mongoc_get_micro_version" (void @-> returning int)

  module Uri = struct
    let new_with_error =
      foreign "mongoc_uri_new_with_error"
        (ptr (const char)
        @-> ptr Bson.Error.t
        @-> returning (ptr Types_generated.Uri.t))

    let destroy =
      foreign "mongoc_uri_destroy" (ptr Types_generated.Uri.t @-> returning void)
  end

  module Database = struct
    let get_collection_names_with_opts =
      foreign "mongoc_database_get_collection_names_with_opts"
        (ptr Types_generated.Database.t
        @-> ptr (const Bson.t)
        @-> ptr Bson.Error.t
        @-> returning (ptr (ptr char)))

    let get_collection =
      foreign "mongoc_database_get_collection"
        (ptr Types_generated.Database.t
        @-> ptr (const char)
        @-> returning (ptr Types_generated.Collection.t))

    let drop =
      foreign "mongoc_database_drop"
        (ptr Types_generated.Database.t @-> ptr Bson.Error.t @-> returning bool)

    let destroy =
      foreign "mongoc_database_destroy"
        (ptr Types_generated.Database.t @-> returning void)
  end

  module Client = struct
    let new_ =
      foreign "mongoc_client_new"
        (ptr (const char) @-> returning (ptr Types_generated.Client.t))

    let new_from_uri =
      foreign "mongoc_client_new_from_uri"
        (ptr (const Types_generated.Uri.t)
        @-> returning (ptr Types_generated.Client.t))

    let new_from_uri_with_error =
      foreign "mongoc_client_new_from_uri_with_error"
        (ptr (const Types_generated.Uri.t)
        @-> ptr Bson.Error.t
        @-> returning (ptr Types_generated.Client.t))

    let get_database_names_with_opts =
      foreign "mongoc_client_get_database_names_with_opts"
        (ptr Types_generated.Client.t
        @-> ptr (const Bson.t)
        @-> ptr Bson.Error.t
        @-> returning (ptr (ptr char)))

    let get_database =
      foreign "mongoc_client_get_database"
        (ptr Types_generated.Client.t
        @-> ptr (const char)
        @-> returning (ptr Types_generated.Database.t))

    let get_collection =
      foreign "mongoc_client_get_collection"
        (ptr Types_generated.Client.t
        @-> ptr (const char)
        @-> ptr (const char)
        @-> returning (ptr Types_generated.Collection.t))

    let destroy =
      foreign "mongoc_client_destroy"
        (ptr Types_generated.Client.t @-> returning void)
  end

  module Collection = struct
    let find_with_opts =
      foreign "mongoc_collection_find_with_opts"
        (ptr Types_generated.Collection.t
        @-> ptr (const Bson.t)
        @-> ptr (const Bson.t)
        @-> ptr (const Types_generated.Read_prefs.t)
        @-> returning (ptr Types_generated.Cursor.t))

    let count_documents =
      foreign "mongoc_collection_count_documents"
        (ptr Types_generated.Collection.t
        @-> ptr (const Bson.t)
        @-> ptr (const Bson.t)
        @-> ptr (const Types_generated.Read_prefs.t)
        @-> ptr Bson.t @-> ptr Bson.Error.t @-> returning int64_t)

    let insert_one =
      foreign "mongoc_collection_insert_one"
        (ptr Types_generated.Collection.t
        @-> ptr (const Bson.t)
        @-> ptr (const Bson.t)
        @-> ptr Bson.t @-> ptr Bson.Error.t @-> returning bool)

    let drop =
      foreign "mongoc_collection_drop"
        (ptr Types_generated.Collection.t
        @-> ptr Bson.Error.t @-> returning bool)

    let destroy =
      foreign "mongoc_collection_destroy"
        (ptr Types_generated.Collection.t @-> returning void)
  end

  module Cursor = struct
    let next =
      foreign "mongoc_cursor_next"
        (ptr Types_generated.Cursor.t
        @-> ptr (ptr (const Bson.t))
        @-> returning bool)

    let error =
      foreign "mongoc_cursor_error"
        (ptr Types_generated.Cursor.t @-> ptr Bson.Error.t @-> returning bool)

    let destroy =
      foreign "mongoc_cursor_destroy"
        (ptr Types_generated.Cursor.t @-> returning void)
  end
end
