module Nemonuri.Dotnet.Handle

module Ht = Nemonuri.Dotnet.HandleType

(* https://github.com/dotnet/runtime/blob/main/src/libraries/System.Reflection.Metadata/src/System/Reflection/Metadata/Handle.cs *)
(* https://github.com/dotnet/runtime/blob/main/src/libraries/System.Reflection.Metadata/src/System/Reflection/Metadata/TypeSystem/Handles.TypeSystem.cs *)

type t = {
  kind : Ht.t;
  value : nat
}

let is_heap_handle (h:t) : Tot bool = Ht.is_heap h.kind
let is_entity_handle (h:t) : Tot bool = not (is_heap_handle h)

let is_nil (h:t) : Tot bool = h.value = 0

let offset (h:t{is_heap_handle h}) : Tot nat = h.value
let row_id (h:t{is_entity_handle h}) : Tot nat = h.value

