module Nemonuri.Ecma335.Metadata.Heap

module M = Nemonuri.Ecma335.Metadata
module Te = Nemonuri.Ecma335.Metadata.TableEntry
module Ter = Nemonuri.Ecma335.Metadata.TableEntry.Refinement
module S = FStar.Set
module Ref = Nemonuri.Ref

open Nemonuri.Ecma335.Metadata.Table
open FStar.Tactics.Typeclasses

class emptyable (a:Type) = {
  is_empty : a -> bool
}

let is_indexing_empty (#data_t:Type) {| e : emptyable data_t |} (table:tablelike Te.t data_t) (te:Te.t{has_id table te}) : Tot bool =
  match Te.is_null te with
  | true -> false
  | false -> table.get_data te |> e.is_empty
  
//--- string ---
type string_data = { ref:Ref.t }

instance emptyable_string : emptyable string_data = {
  is_empty = fun str -> str.ref |> Ref.is_null
}
//---|

//--- guid ---
type guid_data = { ref:Ref.t }

instance emptyable_guid : emptyable guid_data = {
  is_empty = fun g -> g.ref |> Ref.is_null
}
//---|

let is_indexing_empty_string (e:Ter.string_heap_index{not (is_null e)}) : Tot bool =
  false // Todo: be specific

let is_indexing_null_guid (e:guid_heap_index{not (is_null e)}) : Tot bool =
  false // Todo: be specific