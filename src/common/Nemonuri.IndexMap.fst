module Nemonuri.IndexMap

module I = FStar.IntegerIntervals
module Set = FStar.Set
module Map = FStar.Map
module ISet = Nemonuri.IndexSet
module L = FStar.List.Tot
module F = FStar.FunctionalExtensionality

(* Note: 
  Collection 의 원소 타입이 refine 되어야 하는 타입은, 
  unrefined 타입을 정의하고, 그 후 refine predicate 를 정의할 방법이 없는건가?
  방법이 있어도, 비효율적인가? *)
noeq
type unrefined_t (data_t:Type) = {
  domain: ISet.t;
  map: Map.t int data_t
}

let count #data_t (m:unrefined_t data_t) : Tot nat = m.domain.count

type key_value (data_t:Type) = {
  key: int;
  value: data_t
}

let index_map_predicate #data_t (m:unrefined_t data_t) =
  forall (x:int). (
    let in_interval = (I.interval_condition 0 (count m) x) in
    (in_interval ==> (Map.sel m.map x == L.index m.values x)) /\
    (~in_interval ==> (Map.sel m.map x == m.fallback))
  )
    
type t (data_t:Type) = x:unrefined_t data_t{index_map_predicate x}

(* Note:
   FStar 의 기본 Map 은, Set 이나 List 와 다르게 `empty` 가 아니라,
   `const` 또는 `const_on` 으로 구성을 시작하는구나. *)
let empty (#data_t:Type) (fb:data_t) : Tot (t data_t) = 
  {
    values = []; 
    fallback = fb;
    map = Map.const_on ISet.empty.set fb
  }

let push #data_t (m:t data_t) (v:data_t) : Tot (t data_t) =
  {
    //count = m.count + 1;
    //map = FMap.insert m.count v m.map
    values = L.snoc (v.values, v);
    fallback = m.fallback;
    map = Map.upd m.map (count m)
  }

let pop #data_t (m:t data_t{m.count > 0}) : Tot ((t data_t) & (key_value data_t)) =
  let key = m.count - 1 in
  let value = FMap.lookup key m.map in
  let next_map = {
    count = key;
    map = FMap.remove key m.map
  } in
  (next_map, {key = key; value = value})

let domain #data_t (m:t data_t) : Tot (ISet.t) =
  {
    count = m.count;
    set = FMap.domain m.map
  }
