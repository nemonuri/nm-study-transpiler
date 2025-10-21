module Nemonuri.IndexMap

module I = FStar.IntegerIntervals
module FSet = FStar.FiniteSet.Base
open FStar.FiniteSet.Ambient
module FMap = FStar.FiniteMap.Base
open FStar.FiniteMap.Ambient
module ISet = Nemonuri.IndexSet

noeq
type unrefined_t (data_t:Type) = {
  count: nat;
  map: FMap.map int data_t
}

type key_value (data_t:Type) = {
  key: int;
  value: data_t
}

let index_map_predicate #data_t (m:unrefined_t data_t) =
  forall (x:int). (I.interval_condition 0 m.count x) <==> (FMap.mem x m.map)

type t (data_t:Type) = x:unrefined_t data_t{index_map_predicate x}

let empty (data_t:Type) : t data_t = {
  count = 0; map = FMap.emptymap #int #data_t
}

let push #data_t (m:t data_t) (v:data_t) : Tot (t data_t) =
  {
    count = m.count + 1;
    map = FMap.insert m.count v m.map
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
