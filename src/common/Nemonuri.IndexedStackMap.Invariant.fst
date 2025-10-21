module Nemonuri.IndexedStackMap.Invariant

module FMap = FStar.FiniteMap.Base
module FMap = FStar.FiniteMap.Base
module FSet = FStar.FiniteSet.Base
open FStar.FiniteSet.Ambient
open FStar.FiniteMap.Ambient

module I = FStar.IntegerIntervals
private let rec create_indices_set_agg (n: nat) (idx:I.under (n+1)) :
  Tot (FSet.set int)
      (decreases n-idx) =
  match idx = n with
  | true -> FSet.emptyset #int
  | false -> FSet.insert idx (create_indices_set_agg n (idx+1))

type indices_set = FSet.set int

let create_indices_set (n:nat) : Tot indices_set = create_indices_set_agg n 0

type indices_map (data_t:Type) = FMap.map int data_t

noeq
type t (data_t:Type) = {
  count: nat;
  map: indices_map data_t
}

let indexed_stack_map_predicate (#data_t:Type) (m:t data_t) =
  FSet.equal (FMap.domain m.map) (create_indices_set m.count)

