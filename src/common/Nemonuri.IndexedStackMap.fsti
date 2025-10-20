module Nemonuri.IndexedStackMap

module I = FStar.IntegerIntervals
module FMap = FStar.FiniteMap.Base
module FSet = FStar.FiniteSet.Base

val create_indices_set (n: nat) : Tot (FSet.set (I.under n))

val indexed_stack_map_predicate (#n:nat) (#data_t:Type) (m:FMap.map (I.under n) data_t) : Tot Type0
  //FSet.equal (FMap.domain m) (create_indices_set n)

val lemma_create_indices_set_zero () : Lemma (ensures FSet.equal (FSet.emptyset) (create_indices_set 0))

type t (n:nat) (data_t:Type) : Type = x:FMap.map (I.under n) data_t {indexed_stack_map_predicate x}



val empty (data_t:Type) : Tot (t 0 data_t)

//let lemma_empty #n #data_t
