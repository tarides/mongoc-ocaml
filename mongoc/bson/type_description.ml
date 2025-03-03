module Types(F : Ctypes.TYPE) = struct
  open Ctypes_static
  open F

  module Error = struct
    type t
    let t : t structure typ = typedef (structure "bson_error_t") "bson_error_t"
    let domain = field t "domain" uint32_t
    let code = field t "code" uint32_t
    let message = field t "message" (array 504 char)
    let () = seal t
  end

  type t
  let t : t structure typ = typedef (structure "bson_t") "bson_t"
  let () = seal t
end
