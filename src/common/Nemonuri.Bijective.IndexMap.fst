module Nemonuri.Bijective.IndexMap

module I = FStar.IntegerIntervals
module ISet = Nemonuri.IndexSet
open Nemonuri.IndexMap { count, last_key, first_key, key_t, contained_data_t,
                         ensured_data_t, max_key,
                         key_value, is_empty,
                         interval_does_not_contain_value }
open Nemonuri.IndexMap.Unique
module IMap = Nemonuri.IndexMap
module Seq = FStar.Seq.Base
module List = FStar.List.Tot
open FStar.Bijection { (=~) }
module B = FStar.Bijection

let interval_is_bijective (#data_t:eqtype) (m:IMap.t data_t) (min:key_t m) (imax:key_t m) =
  forall (x:key_t m). (I.interval_condition min (imax+1) x) ==>
    ((min = imax) <==> (IMap.select m min = IMap.select m imax))

let bijective_index_map_predicate (#data_t:eqtype) (m:IMap.t data_t) =
  forall (x:contained_data_t m). (unique_data_predicate m x)
  //m |> IMap.to_seq |> Seq.seq_to_list |> List.noRepeats

(*
let lemma_bijective_index_map_predicate (#data_t:eqtype) (m:IMap.ensured_t data_t)
  : Lemma ((interval_is_bijective m 0 (max_key m)) <==> (bijective_index_map_predicate m))
  =
  ()
*)

(*
private let rec is_bijective_agg' 
  (#data_t:eqtype) (m:IMap.t data_t) 
  (asc_select_key:key_t m) (des_compare_key:key_t m{des_compare_key < asc_select_key})
  =
*)


type t (data_t:eqtype) = x:IMap.t data_t{bijective_index_map_predicate x}

type ensured_t (data_t:eqtype) = x:t data_t{not (is_empty x)}

let lemma_key #data_t (m:t data_t) (key:key_t m)
  : Lemma (unique_key_predicate m key) =
  ()

let select #data_t (m:t data_t) (key:unique_key_t m) : Tot (unique_data_t m) = IMap.select m key
let unique_key #data_t (m:t data_t) (v:unique_data_t m) : Tot (unique_key_t m) = IMap.first_key m v


let empty (#data_t:eqtype) (fb:data_t) : Tot (t data_t) = IMap.empty fb

let fresh_data_predicate #data_t (m:t data_t) (v:ensured_data_t m) : Tot bool = not (IMap.contains_value m v)
type fresh_data_t #data_t (m:t data_t) = x:ensured_data_t m{fresh_data_predicate m x}




//let lemma_push_fresh_data_unique #data_t (m:t data_t) (v:fresh_data_t m)

(*
let pop #data_t (m:ensured_t data_t) : Tot ((t data_t) & (key_value data_t)) =
  let ( m2, kv ) = IMap.pop m in
  ( m2, kv )
*)

let push #data_t (m:t data_t) (v:fresh_data_t m) 
  : Tot (t data_t) = 
  let next_m = IMap.push m v in
  assert (interval_does_not_contain_value next_m v 0 (count m));
  assert (~(interval_does_not_contain_value next_m v 0 (count next_m)));
  assert ((last_key next_m v) = (first_key next_m v));
  assert (unique_data_predicate next_m v);
  //assume (IMap.first_key next_m v = IMap.max_key next_m);
  //assume (IMap.last_key next_m v = IMap.max_key next_m);
  //assert (IMap.first_key next_m v = IMap.last_key next_m v);
  //assume (forall (x:key_t m). (unique_key_predicate next_m x));
  //assert (unique_data_predicate next_m v);
  assume (bijective_index_map_predicate next_m);
  next_m
  


