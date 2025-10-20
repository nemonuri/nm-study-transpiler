module Nemonuri.IndexedStackMap.Invariant

include Nemonuri.IndexedStackMap { t as variant_t }
module FMap = FStar.FiniteMap.Base

noeq
type t (data_t:Type) = {
  count: nat;
  v: variant_t count data_t
}

//let variant_elim 