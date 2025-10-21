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

(*
let lemma_insert (s:t) (x:int)
  : Lemma ((I.interval_condition 0 (s.count+1) x) <==> (FSet.mem x (FSet.insert (s.count+1) s.set)))
  =
  let lhs = (I.interval_condition 0 (s.count+1) x) in
  let rhs = (FSet.mem x (FSet.insert (s.count+1) s.set)) in
  let lemma_l_to_r' () : Lemma (lhs ==> rhs) =
    match lhs with
    | false -> () | true ->
    match (I.interval_condition 0 s.count x) with
    | true -> assert (FSet.mem x s.set) | false ->
    assert 
  in
  let lemma_r_to_l' () : Lemma (rhs ==> lhs) =
    admit ()
  in
  lemma_l_to_r' ();
  lemma_r_to_l' ()
*)

module C = FStar.Classical

let push (s:t) : Tot t =
  //C.forall_intro (lemma_insert s);
  {
    count = s.count + 1;
    set = FSet.insert s.count s.set
  }
