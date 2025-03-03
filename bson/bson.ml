open Ctypes

type t = Types_generated.t structure
let t = Types_generated.t

module Error = struct
  type t = (Types_generated.Error.t, [`Struct]) structured
  let t = Types_generated.Error.t
  let domain (error : t) =
    getf error Types_generated.Error.domain |> Unsigned.UInt32.to_int
  let code error =
    getf error Types_generated.Error.code |> Unsigned.UInt32.to_int
  let message error =
    getf error Types_generated.Error.message
    |> CArray.to_list
    |> List.to_seq
    |> String.of_seq
end

(* ( const uint8_t * ) *)
let new_from_json ?len data : (t, string) result =
  let len = PosixTypes.Ssize.(Option.fold ~none:minus_one ~some:of_int len) in
  let json = Ctypes_std_views.char_ptr_of_string data in
  let json = coerce (ptr char) (ptr (const uint8_t)) json in
  let error = make Types_generated.Error.t in
  let bson = C.Functions.new_from_json json len (addr error) in
  if is_null bson then
    Result.Error ("JSON parsing Error: " ^ Error.message error)
  else
    Result.Ok !@bson

(*  ( const bson_t * )  *)
let as_json ?length (bson : t) =
  let ptr = allocate t bson in
  let length =
    let some u = u |> Unsigned.Size_t.of_int |> allocate size_t in
    Option.fold ~none:(from_voidp size_t null) ~some length in
  let str = C.Functions.as_json ptr length in
  Ctypes_std_views.string_of_char_ptr str
  (* TODO: C.Functions.free (to_voidp str) *)
