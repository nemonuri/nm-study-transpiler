module Nemonuri.Ecma335.Metadata.TableEntry.Refinement

module M = Nemonuri.Ecma335.Metadata
module Te = Nemonuri.Ecma335.Metadata.TableEntry
module Rf = Nemonuri.Refinement.Tot
module F = FStar.FunctionalExtensionality

let string_heap_index : Rf.t Te.t = {
  predicate = F.on Te.t Te.StringHeap?
}

let guid_heap_index : Rf.t Te.t = {
  predicate = F.on Te.t Te.GuidHeap?
}

let assert_string_and_guid_indexes_are_distinct (s:Rf.refine string_heap_index) (g:Rf.refine guid_heap_index) = assert (~(s === g))