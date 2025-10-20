module Nemonuri.IndexedStackMap

module I = FStar.IntegerIntervals
module FMap = FStar.FiniteMap.Base
module FSet = FStar.FiniteSet.Base


val create_indices_set (n: nat) : Tot (FSet.set (I.under n))

val indexed_stack_map_predicate (#n:nat) (#data_t:Type) (m:FMap.map (I.under n) data_t) : Tot Type0

val lemma_create_indices_set_zero () : Lemma (ensures FSet.equal (FSet.emptyset) (create_indices_set 0))

val t (n:nat) (data_t:Type u#data_t) : Type u#data_t

val empty (data_t:Type) : Tot (t 0 data_t)

//let lemma_empty #n #data_t
