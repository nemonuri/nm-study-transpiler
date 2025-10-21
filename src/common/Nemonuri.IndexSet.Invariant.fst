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

//module C = FStar.Classical

let push (s:t) : Tot t =
  {
    count = s.count + 1;
    set = FSet.insert s.count s.set
  }

let pop (s:t{s.count > 0}) : Tot (t & nat) =
  let popped = s.count - 1 in
  let next_set = {
    count = popped;
    set = FSet.remove popped s.set
  } in
  (next_set, popped)

let rec push_many (s:t) (n:nat) 
  : Tot t (decreases n) =
  match n with
  | 0 -> s
  | n' -> push_many (push s) (n-1)

let create (n:nat) : Tot t =
  push_many empty n
