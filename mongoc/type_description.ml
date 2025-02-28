module Types(F : Ctypes.TYPE) = struct
  open Ctypes
  open F

  module Error = struct
    type t
    let t : t structure typ = typedef (structure "bson_error_t") "bson_error_t"
    let () = seal t
  end

  module Client = struct
    type t
    let t : t structure typ = typedef (structure "_mongoc_client_t") "mongoc_client_t"
    (* Not sealing incomplete type. See https://github.com/yallop/ocaml-ctypes/issues/237 *)
  end

  module Collection = struct
    type t
    let t : t structure typ = typedef (structure "_mongoc_collection_t") "mongoc_collection_t"
  end

  module Cursor = struct
    type t
    let t : t structure typ = typedef (structure "_mongoc_cursor_t") "mongoc_cursor_t"
  end

  module Read_prefs = struct
    type t
    let t : t structure typ = typedef (structure "_mongoc_read_prefs_t") "mongoc_read_prefs_t"
  end
end
