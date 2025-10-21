module Nemonuri.IndexSet.Invariant

module I = FStar.IntegerIntervals
module FSet = FStar.FiniteSet.Base
open FStar.FiniteSet.Ambient

noeq
type unrefined_t = {
  count: nat;
  set: FSet.set int
}

let index_set_predicate (s:unrefined_t) =
  forall (x:int). (I.interval_condition 0 s.count x) <==> (FSet.mem x s.set)

type t = x:unrefined_t{index_set_predicate x}

let empty : t = {
  count = 0; set = FSet.emptyset #int
}

let lemma_insert (s:t) (x:int)
  : Lemma ((I.interval_condition 0 (s.count+1) x) <==> (FSet.mem x (FSet.insert (s.count+1) s.set)))
  =
  ()

(*
let push (s:t) : Tot t =
  let next_count = s.count + 1 in
  {
    count = next_count;
    set = FSet.insert next_count s.set
  }
*)