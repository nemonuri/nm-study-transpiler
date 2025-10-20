module Nemonuri.IndexedStackMap

module I = FStar.IntegerIntervals
module FMap = FStar.FiniteMap.Base
module FSet = FStar.FiniteSet.Base


private let rec create_indices_set_agg (n: nat) (idx:I.under (n+1)) :
  Tot (FSet.set (I.under n))
      (decreases n-idx) =
  match idx = n with
  | true -> FSet.emptyset #(I.under n)
  | false -> FSet.insert idx (create_indices_set_agg n (idx+1))

let create_indices_set (n: nat) : Tot (FSet.set (I.under n)) =
  create_indices_set_agg n 0

let indexed_stack_map_predicate (#n:nat) (#data_t:Type) (m:FMap.map (I.under n) data_t) = FSet.equal (FMap.domain m) (create_indices_set n)

open FStar.FiniteSet.Ambient
open FStar.FiniteMap.Ambient
let lemma_create_indices_set_zero () = admit ()

type t n data_t = x:FMap.map (I.under n) data_t {indexed_stack_map_predicate x}


let empty (data_t:Type) : Tot (t 0 data_t) = FMap.emptymap #(I.under 0) #data_t

