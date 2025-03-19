open Ctypes_static

let ( !@ ) = Ctypes.( !@ )

type t = Types_generated.t structure

let t : t typ = Types_generated.t

module Error = struct
  type t = Types_generated.Error.t structure

  let t : t typ = Types_generated.Error.t

  let domain (error : t) =
    Ctypes.getf error Types_generated.Error.domain |> Unsigned.UInt32.to_int

  let code (error : t) =
    Ctypes.getf error Types_generated.Error.code |> Unsigned.UInt32.to_int

  let message (error : t) =
    Ctypes.getf error Types_generated.Error.message
    |> Ctypes.CArray.to_list |> List.to_seq |> String.of_seq
end

let some = Ctypes.allocate t
let none = Ctypes.(from_voidp t null)

let get_version () =
  () |> C.Functions.get_version |> Ctypes_std_views.string_of_char_ptr

let get_major_version () =
  () |> C.Functions.get_major_version |> Signed.Int.to_int

let get_minor_version () =
  () |> C.Functions.get_minor_version |> Signed.Int.to_int

let get_micro_version () =
  () |> C.Functions.get_micro_version |> Signed.Int.to_int

let new_from_json ?length data : (t, Error.t) result =
  let length =
    PosixTypes.Ssize.(Option.fold ~none:minus_one ~some:of_int length)
  in
  let json = Ctypes_std_views.char_ptr_of_string data in
  let json = Ctypes.coerce (ptr char) (ptr (const uint8_t)) json in
  let error = Ctypes.make Types_generated.Error.t in
  let bson = C.Functions.new_from_json json length (Ctypes.addr error) in
  if Ctypes.is_null bson then Result.Error error else Result.Ok !@bson

let as_canonical_extended_json ?length (bson : t) =
  let ptr = Ctypes.allocate t bson in
  let length =
    let some u = u |> Unsigned.Size_t.of_int |> Ctypes.allocate size_t in
    Option.fold ~none:(Ctypes.from_voidp size_t Ctypes.null) ~some length
  in
  let str = C.Functions.as_canonical_extended_json ptr length in
  Ctypes_std_views.string_of_char_ptr str
(* TODO: C.Functions.free (to_voidp str) *)

let as_relaxed_extended_json ?length (bson : t) =
  let ptr = Ctypes.allocate t bson in
  let length =
    let some u = u |> Unsigned.Size_t.of_int |> Ctypes.allocate size_t in
    Option.fold ~none:(Ctypes.from_voidp size_t Ctypes.null) ~some length
  in
  let str = C.Functions.as_relaxed_extended_json ptr length in
  Ctypes_std_views.string_of_char_ptr str
(* TODO: C.Functions.free (to_voidp str) *)

let as_json = as_relaxed_extended_json
