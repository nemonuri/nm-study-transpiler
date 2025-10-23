module Nemonuri.IndexMap

module I = FStar.IntegerIntervals
module Set = FStar.Set
module Map = FStar.Map
module ISet = Nemonuri.IndexSet
module L = FStar.List.Tot
module F = FStar.FunctionalExtensionality
module En = Nemonuri.Ensured

(* Note: 
  Collection 의 원소 타입이 refine 되어야 하는 타입은, 
  unrefined 타입을 정의하고, 그 후 refine predicate 를 정의할 방법이 없는건가?
  방법이 있어도, 비효율적인가? *)
noeq
type unrefined_t (data_t:Type) = {
  domain: ISet.t;
  fallback: data_t;
  map: Map.t int data_t
}

let count #data_t (m:unrefined_t data_t) : Tot nat = m.domain.count

let contains #data_t (m:unrefined_t data_t) (x:int) : Tot bool = ISet.mem m.domain x

let is_empty #data_t (m:unrefined_t data_t) : Tot bool = (count m) = 0

let lemma_contains #data_t (m:unrefined_t data_t) (x:int)
  : Lemma (ensures (contains m x) <==> (I.interval_condition 0 (count m) x)) =
  ()

let lemma_contains_lesser #data_t (m:unrefined_t data_t) (x1:int) (x2:int)
  : Lemma (requires (contains m x1) /\ (I.interval_condition 0 x1 x2))
          (ensures (contains m x2))
  =
  ()

type key_value (data_t:Type) = {
  key: int;
  value: data_t
}

let index_map_predicate #data_t (m:unrefined_t data_t) =
  forall (x:int). (
    let in_domain = contains m x in
    (in_domain <==> (Map.contains m.map x)) /\
    (~in_domain <==> (Map.sel m.map x == m.fallback))
  )
    
type t (data_t:Type) = x:unrefined_t data_t{index_map_predicate x}

type ensured_t (data_t:Type) = x:t data_t{not (is_empty x)}

let lemma_ensured #data_t (m:ensured_t data_t)
  : Lemma ((count m) > 0) =
  ()

type ensured_data_t #data_t (m:t data_t) = En.t m.fallback

type key_t #data_t (m:t data_t) = x:int{contains m x}

let max_key #data_t (m:ensured_t data_t) : Tot (key_t m) =
  (count m) - 1

let select #data_t (m:t data_t) (key:int{contains m key}) : Tot data_t = Map.sel m.map key

let lemma_select #data_t (m:t data_t) (key:int{contains m key})
  : Lemma (select m key =!= m.fallback) =
  ()

let interval_does_not_contain_value (#data_t:eqtype) (m:t data_t) (v:data_t) (min:int) (max:int) = 
  (forall (x:int). 
      {:pattern (contains m x) \/ (I.interval_condition min max x) \/ (select m x = v)}
      ((contains m x) /\ (I.interval_condition min max x)) ==> ~(select m x = v))

(* Node: 증명을 위해, 해당 함수의 해당 ensures 는 꼭 존재해야 한다. *)
private let rec contains_value_agg' 
  (#data_t:eqtype) (m:t data_t) (v:ensured_data_t m) (desending_key:key_t m) 
  : Pure bool 
      (requires True)
      (ensures fun b -> (b ==> ~(interval_does_not_contain_value m v 0 (count m))))
      (decreases desending_key)
  =
  match select m desending_key = v with | true -> true 
  | false -> 
  match desending_key = 0 with | true -> false
  | false ->
  contains_value_agg' m v (desending_key-1)


let contains_value (#data_t:eqtype) (m:t data_t) (v:data_t) : Tot bool =
  match v = m.fallback with | true -> false 
  | false ->
  match is_empty m with | true -> false 
  | false ->
  contains_value_agg' m v (max_key m)

let lemma_contains_value (#data_t:eqtype) (m:t data_t) (v:data_t)
  : Lemma (requires interval_does_not_contain_value m v 0 (count m))
          (ensures (contains_value m v) = false)
  = ()

type contained_data_t (#data_t:eqtype) (m:t data_t) = x:data_t{contains_value m x}

let lemma_contained_data (#data_t:eqtype) (m:t data_t) (v:contained_data_t m)
  : Lemma ((En.ensured_predicate m.fallback v) /\ (not (is_empty m))) =
  ()

(* Note: 해당 함수의 해당 requires 는 꼭 존재해야 한다. *)
private let rec last_key_agg' (#data_t:eqtype) (m:t data_t) (v:contained_data_t m) (desending_key:key_t m)
  : Pure (key_t m)
      (requires (interval_does_not_contain_value m v (desending_key+1) (count m)))
      (ensures fun _ -> True)
      (decreases desending_key)
  =
  match select m desending_key = v with 
  | true -> desending_key
  | false -> last_key_agg' m v (desending_key-1)
  
let last_key (#data_t:eqtype) (m:t data_t) (v:contained_data_t m)
  : Tot (key_t m)
  =
  last_key_agg' m v (max_key m)

(* Note:
   FStar 의 기본 Map 은, Set 이나 List 와 다르게 `empty` 가 아니라,
   `const` 또는 `const_on` 으로 구성을 시작하는구나. *)
let empty (#data_t:Type) (fb:data_t) : Tot (t data_t) = 
  {
    domain = ISet.empty; 
    fallback = fb;
    map = Map.const_on ISet.empty.set fb
  }

let push #data_t (m:t data_t) (v:En.t m.fallback) : Tot (t data_t) =
  {
    domain = ISet.push m.domain;
    fallback = m.fallback;
    map = Map.upd m.map (count m) v
  }

let pop #data_t (m:t data_t{(count m) > 0}) : Tot ((t data_t) & (key_value data_t)) =
  let ( next_domain, key ) = ISet.pop m.domain in
  let value = Map.sel m.map key in
  let next_map = {
    domain = next_domain;
    fallback = m.fallback;
    (* Note: FStar 기본 맵에는 'remove'가 없어서, fallback 값으로 update 한 후 restrict 해야 하는구나. *)
    map = Map.upd m.map key m.fallback |> Map.restrict next_domain.set
  } in
  (next_map, {key = key; value = value})

(*
let domain #data_t (m:t data_t) : Tot (ISet.t) =
  {
    count = m.count;
    set = FMap.domain m.map
  }
*)

module Seq = FStar.Seq.Base

let to_seq #data_t (m:t data_t) 
  : Tot (Seq.seq data_t)
  =
  Seq.init (count m) (select m)
