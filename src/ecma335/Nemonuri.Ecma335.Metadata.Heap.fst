module Nemonuri.Ecma335.Metadata.Heap

module M = Nemonuri.Ecma335.Metadata
module Te = Nemonuri.Ecma335.Metadata.TableEntry
module S = FStar.Set

open Nemonuri.Ecma335.Metadata.Table
open FStar.Tactics.Typeclasses

//assume val string_data : Type0
//assume val guid_data : Type0

class emptyable (a:Type) = {
  is_empty : a -> bool
}

let is_indexing_empty (#data_t:Type) {| e : emptyable data_t |} (table:tablelike Te.t data_t) (te:Te.t) : Tot bool =
  match Te.is_null te with
  | true -> false
  | false ->
  match S.mem te table.id_set with
  | false -> false
  | true -> table.get_data te |> e.is_empty
  

//instance tablelike_string_heap {| e : emptyable string_data |} : tablelike Te.string_heap_index string_data = {
//  try_get_data = fun _ -> None
//}
