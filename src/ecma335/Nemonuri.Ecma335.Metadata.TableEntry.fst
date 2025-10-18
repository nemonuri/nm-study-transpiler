module Nemonuri.Ecma335.Metadata.TableEntry

module M = Nemonuri.Ecma335.Metadata

type t =
  | StringHeap : (v:nat) -> t
  | GuidHeap : (v:nat) -> t

let get_storage_structure_kind (e:t) : Tot M.storage_structure_kind =
  match e with
  | StringHeap _ -> M.Heap
  | GuidHeap _ -> M.Heap

let get_heap_kind (e:t{get_storage_structure_kind e = M.Heap})
  : Tot M.heap_kind =
  match e with
  | StringHeap _ -> M.String
  | GuidHeap _ -> M.Guid

let get_table_entry_kind (e:t) : Tot M.table_entry_kind =
  match get_storage_structure_kind e with
  | M.Heap -> M.Index
  | _ -> M.Constant // Todo: be specific

let get_value (e:t) : Tot nat =
  match e with
  | StringHeap v -> v
  | GuidHeap v -> v

type string_heap_index = x:t{StringHeap? x}
type guid_heap_index = x:t{GuidHeap? x}

let assert_string_and_guid_indexes_are_distinct (s:string_heap_index) (g:guid_heap_index) = assert (s <> g)

let is_null (e:t) : Tot bool = get_value e |> M.is_null
let is_not_null (e:t) : Tot bool = get_value e |> M.is_not_null

let is_indexing_empty_string (e:string_heap_index{not (is_null e)}) : Tot bool =
  false // Todo: be specific

let is_indexing_null_guid (e:guid_heap_index{not (is_null e)}) : Tot bool =
  false // Todo: be specific