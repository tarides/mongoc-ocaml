module Functions (F : Ctypes.FOREIGN) = struct
  open Ctypes_static
  open F

  let get_version =
    foreign "bson_get_version" (void @-> returning (ptr (const char)))

  let get_major_version =
    foreign "bson_get_major_version" (void @-> returning int)

  let get_minor_version =
    foreign "bson_get_minor_version" (void @-> returning int)

  let get_micro_version =
    foreign "bson_get_micro_version" (void @-> returning int)

  let new_from_json =
    foreign "bson_new_from_json"
      (ptr (const uint8_t)
      @-> PosixTypes.ssize_t
      @-> ptr Types_generated.Error.t
      @-> returning (ptr Types_generated.t))

  let as_canonical_extended_json =
    foreign "bson_as_canonical_extended_json"
      (ptr (const Types_generated.t) @-> ptr size_t @-> returning (ptr char))

  let as_relaxed_extended_json =
    foreign "bson_as_relaxed_extended_json"
      (ptr (const Types_generated.t) @-> ptr size_t @-> returning (ptr char))

  let free = foreign "bson_free" (ptr void @-> returning void)
end
