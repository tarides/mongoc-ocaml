module Types = Types_generated

module Functions(F : Ctypes.FOREIGN) = struct
  open Ctypes_static
  open F

  let new_from_json = foreign "bson_new_from_json" (ptr (const uint8_t) @-> PosixTypes.ssize_t @-> ptr Types.Error.t @-> returning (ptr Types.t))
  let as_json = foreign "bson_as_json" (ptr (const Types.t) @-> ptr size_t @-> returning (ptr char))
  let as_canonical_extended_json = foreign "bson_as_canonical_extended_json" (ptr (const Types.t) @-> ptr size_t @-> returning (ptr char))
  let free = foreign "bson_free" (ptr void @-> returning void)
end
