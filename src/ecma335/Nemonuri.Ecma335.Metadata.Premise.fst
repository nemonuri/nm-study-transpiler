module Nemonuri.Ecma335.Metadata.Premise

module Heap = Nemonuri.Ecma335.Metadata.Heap

noeq
type t = {
  string_heap: Heap.string_heap;
  guid_heap: Heap.guid_heap;
}