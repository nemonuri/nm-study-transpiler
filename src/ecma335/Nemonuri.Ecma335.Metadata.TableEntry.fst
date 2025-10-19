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



let is_null (e:t) : Tot bool = get_value e |> M.is_null
let is_not_null (e:t) : Tot bool = get_value e |> M.is_not_null

