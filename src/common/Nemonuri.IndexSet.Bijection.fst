module Nemonuri.IndexSet.Bijection

module ISet = Nemonuri.IndexSet
module I = FStar.IntegerIntervals
module FSet = FStar.FiniteSet.Base
open FStar.FiniteSet.Ambient
open FStar.Bijection { ( =~ ) }
module B = FStar.Bijection

noeq
type unrefined_t (dom_t:eqtype) = {
  count: nat;
  set: FSet.set dom_t;
  bijection: dom_t =~ int;
  dom_refiner: dom_t -> Tot bool
}

let index_set_predicate #dom_t (s:unrefined_t dom_t) =
  (forall (x:dom_t). (s.dom_refiner x) <==> (FSet.mem x s.set)) /\
  (forall (x:dom_t). (s.dom_refiner x) <==> (I.interval_condition 0 s.count (s.bijection.right x)))

type t (dom_t:eqtype) = x:unrefined_t dom_t{index_set_predicate x}

//private let assert_cardinality #dom_t (s:t dom_t) = assert ( FSet.cardinality s.set == s.count )

