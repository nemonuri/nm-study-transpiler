module Nemonuri.Bijective.IndexMap

module I = FStar.IntegerIntervals
module ISet = Nemonuri.IndexSet
open Nemonuri.IndexMap { count, last_key, first_key, key_t, contained_data_t,
                         ensured_data_t, max_key,
                         key_value_t, is_empty, lemma_push_pop, lemma_pop_push }
open Nemonuri.IndexMap.Unique { map_is_distinct, unique_key_predicate, lemma_map_is_distinct,
                                unique_key_t, unique_data_t }
module IMap = Nemonuri.IndexMap
module Cl = FStar.Classical

let bijective_index_map_predicate (#data_t:eqtype) (m:IMap.t data_t) = map_is_distinct m

type t (data_t:eqtype) = x:IMap.t data_t{bijective_index_map_predicate x}

type ensured_t (data_t:eqtype) = x:t data_t{not (is_empty x)}

let lemma_key #data_t (m:t data_t) (key:key_t m)
  : Lemma (unique_key_predicate m key) =
  lemma_map_is_distinct m

let select #data_t (m:t data_t) (key:unique_key_t m) : Tot (unique_data_t m) = IMap.select m key
let unique_key #data_t (m:t data_t) (v:unique_data_t m) : Tot (unique_key_t m) = IMap.first_key m v


let empty (#data_t:eqtype) (fb:data_t) : Tot (t data_t) = IMap.empty fb

let fresh_data_predicate (#data_t:eqtype) (m:IMap.t data_t) (v:ensured_data_t m) : Tot bool = not (IMap.contains_value m v)
type fresh_data_t (#data_t:eqtype) (m:IMap.t data_t) = x:ensured_data_t m{fresh_data_predicate m x}

let lemma_fresh_data (#data_t:eqtype) (m:IMap.t data_t) (v:ensured_data_t m)
  : Lemma (((bijective_index_map_predicate m) /\ (fresh_data_predicate m v)) <==>
           (bijective_index_map_predicate (IMap.push m v)))
  =
  let pl = ((bijective_index_map_predicate m) /\ (fresh_data_predicate m v)) in
  let pr = (bijective_index_map_predicate (IMap.push m v)) in
  let lemma_pl_to_pr () : Lemma (requires pl) (ensures pr) =
    admit ()
  in
  let lemma_pr_to_pl () : Lemma (requires pr) (ensures pl) =
    admit ()
  in
  Cl.move_requires lemma_pl_to_pr ();
  Cl.move_requires lemma_pr_to_pl ()

let push #data_t (m:t data_t) (v:fresh_data_t m) 
  : Tot (t data_t) = 
  lemma_fresh_data m v;
  IMap.push m v

let pop #data_t (m:ensured_t data_t) : Tot ((t data_t) & (key_value_t data_t)) =
  let ( m2, kv ) = IMap.pop m in
  lemma_pop_push m;
  ( m2, kv )



