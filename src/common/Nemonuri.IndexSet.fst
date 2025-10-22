module Nemonuri.IndexSet

module I = FStar.IntegerIntervals
module Set = FStar.Set

(* Node:
   'Set' 은 '구성(Construction) 가능한 술어(Predicate)'로,
   'Map' 은 '구성 가능한 함수'로 생각할 수 있다.
*)

noeq
type unrefined_t = {
  count: nat;
  set: Set.set int
}

let index_set_predicate (s:unrefined_t) =
  forall (x:int). ((Set.mem x s.set) <==> (I.interval_condition 0 s.count x))

type t = x:unrefined_t{index_set_predicate x}

let mem (s:t) (x:int) : Tot bool = Set.mem x s.set

let empty : t = {
  count = 0; set = Set.empty #int
}

let push (s:t) : Tot t =
  {
    count = s.count + 1;
    set = Set.add s.count s.set
  }

let pop (s:t{s.count > 0}) : Tot (t & nat) =
  let popped = s.count - 1 in
  let next_set = {
    count = popped;
    set = Set.remove popped s.set
  } in
  (next_set, popped)

let rec push_many (s:t) (n:nat) 
  : Tot t (decreases n) =
  match n with
  | 0 -> s
  | n' -> push_many (push s) (n-1)

let create (n:nat) : Tot t =
  push_many empty n

