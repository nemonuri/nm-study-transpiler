module Nemonuri.Ecma335.Metadata.TableEntry.Refinement

module M = Nemonuri.Ecma335.Metadata
module Te = Nemonuri.Ecma335.Metadata.TableEntry

let string_heap_index_predicate = Te.StringHeap?
let string_heap_index = x:Te.t{string_heap_index_predicate x}

let guid_heap_index_predicate = Te.GuidHeap?
let guid_heap_index = x:Te.t{guid_heap_index_predicate x}

let assert_string_and_guid_indexes_are_distinct (s:string_heap_index) (g:guid_heap_index) = assert (s <> g)

let module_table_index_predicate = Te.ModuleTable?
let module_table_index = x:Te.t{module_table_index_predicate x}