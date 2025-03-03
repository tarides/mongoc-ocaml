module Types = Types_generated

module Functions (F : Ctypes.FOREIGN) = struct
  open Ctypes_static
  open F

  let init = foreign "mongoc_init" (void @-> returning void)
  let cleanup = foreign "mongoc_cleanup" (void @-> returning void)

  module Uri = struct
    let new_with_error =
      foreign "mongoc_uri_new_with_error"
        (ptr (const char) @-> ptr Bson.Error.t @-> returning (ptr Types.Uri.t))

    let destroy =
      foreign "mongoc_uri_destroy" (ptr Types.Uri.t @-> returning void)
  end

  module Client = struct
    let new_ =
      foreign "mongoc_client_new"
        (ptr (const char) @-> returning (ptr Types.Client.t))

    let new_from_uri =
      foreign "mongoc_client_new_from_uri"
        (ptr (const Types.Uri.t) @-> returning (ptr Types.Client.t))

    let new_from_uri_with_error =
      foreign "mongoc_client_new_from_uri_with_error"
        (ptr (const Types.Uri.t)
        @-> ptr Bson.Error.t
        @-> returning (ptr Types.Client.t))

    let get_collection =
      foreign "mongoc_client_get_collection"
        (ptr Types.Client.t
        @-> ptr (const char)
        @-> ptr (const char)
        @-> returning (ptr Types.Collection.t))

    let destroy =
      foreign "mongoc_client_destroy" (ptr Types.Client.t @-> returning void)
  end

  module Collection = struct
    let find_with_opts =
      foreign "mongoc_collection_find_with_opts"
        (ptr Types.Collection.t
        @-> ptr (const Bson.t)
        @-> ptr (const Bson.t)
        @-> ptr (const Types.Read_prefs.t)
        @-> returning (ptr Types.Cursor.t))

    let destroy =
      foreign "mongoc_collection_destroy"
        (ptr Types.Collection.t @-> returning void)
  end

  module Cursor = struct
    let next =
      foreign "mongoc_cursor_next"
        (ptr Types.Cursor.t @-> ptr (ptr (const Bson.t)) @-> returning bool)

    let error =
      foreign "mongoc_cursor_error"
        (ptr Types.Cursor.t @-> ptr Bson.Error.t @-> returning bool)

    let destroy =
      foreign "mongoc_cursor_destroy" (ptr Types.Cursor.t @-> returning void)
  end
end
