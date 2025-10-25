module Nemonuri.IndexMap

module I = FStar.IntegerIntervals
module Set = FStar.Set
module Map = FStar.Map
module ISet = Nemonuri.IndexSet
module L = FStar.List.Tot
module F = FStar.FunctionalExtensionality
module En = Nemonuri.Ensured
module Cl = FStar.Classical
module Ls = Nemonuri.LinearSearch
//module Ui = Nemonuri.Unique.IntegerIntervals

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
type key_or_count_t #data_t (m:t data_t) = x:int{contains m x || (count m) = x}

let max_key #data_t (m:ensured_t data_t) : Tot (key_t m) =
  (count m) - 1

let select #data_t (m:t data_t) (key:key_t m) : Tot data_t = Map.sel m.map key

let lemma_select #data_t (m:t data_t) (key:key_t m)
  : Lemma (select m key =!= m.fallback) =
  ()

let equal_selection (#data_t:eqtype) (m:t data_t) (v:data_t) (k:key_t m)
  : Tot bool = select m k = v

let equal_selection_key (#data_t:eqtype) (m:t data_t) (k1:key_t m) (k2:key_t m)
  : Tot bool = let v = select m k1 in equal_selection m v k2

let lemma_equal_selection_key (#data_t:eqtype) (m:t data_t) (k:key_t m)
  : Lemma (equal_selection_key m k k) =
  ()

//let equal_selection_restricted (#data_t:eqtype) (m:t data_t) (v:data_t) (imin:int) (emax:int) = 
//  ((contains m imin) /\ ((contains m emax) \/ ((count m) = emax))) ==> 
//  (Ui.is_restricted imin emax (equal_selection m v))

//let equal_selection_exist (#data_t:eqtype) (m:t data_t) (v:data_t) (imin:int) (emax:int) = 
//  (contains m imin) /\ (contains m emax) /\ (Ui.is_exist imin emax (equal_selection m v))

//  (forall (x:int). 
//      {:pattern (contains m x) \/ (I.interval_condition imin emax x) \/ (select m x = v)}
//      ((contains m x) /\ (I.interval_condition imin emax x)) ==> ~(select m x = v))

(* Note: 증명을 위해, 해당 함수의 해당 ensures 는 꼭 존재해야 한다. *)
(* Note: 이런 재귀 함수의 ensures 는, 가능한 '동치'식으로 명세하라! 그래야 편하다! *)
(*
private let rec contains_value_agg' 
  (#data_t:eqtype) (m:t data_t) (v:ensured_data_t m) (desending_key:key_t m) 
  : Pure bool 
      //(requires True)
      (requires (equal_selection_restricted m v (desending_key+1) (count m)))
      (ensures fun b -> //(~b ==> equal_selection_restricted m v desending_key (count m)) /\
                        //(b ==> forall (x:key_t m{x >= desending_key}). (contains_value_agg' m v x))
                        (b <==> (equal_selection_restricted m v (desending_key+1) (count m)) /\
                                ~(equal_selection_restricted m v 0 (desending_key+1))))
      (decreases desending_key)
  =
  match equal_selection m v desending_key with | true -> true 
  | false -> 
  match desending_key = 0 with | true -> false
  | false ->
  contains_value_agg' m v (desending_key-1)
*)

(*
private let lemma_contains_value_agg'
  (#data_t:eqtype) (m:t data_t) (v:ensured_data_t m) (desending_key:key_t m) (ge_key:key_t m{ge_key >= desending_key})
  : Lemma (requires (contains_value_agg' m v desending_key))
          (ensures (contains_value_agg' m v ge_key))
  =
  admit ()
*)

let contains_value (#data_t:eqtype) (m:t data_t) (v:data_t) : Tot bool =
  match v = m.fallback with | true -> false 
  | false ->
  match is_empty m with | true -> false 
  | false ->
  Ls.desending_find 0 (count m) (equal_selection m v) |> Some?
  //contains_value_agg' m v (max_key m)

//let lemma_contains_value (#data_t:eqtype) (m:t data_t) (v:data_t)
//  : Lemma (~(equal_selection_restricted m v 0 (count m)) <==> (contains_value m v))
//  = 
//  ()
  //let p1 = (equal_selection_restricted m v 0 (count m)) in
  //let p2 = (contains_value m v) in
  //assert (p2 ==> ~p1); // r to l
  //assert (~p2 ==> p1) // l to r
  


//let lemma_select_to_contains_value (#data_t:eqtype) (m:t data_t) (key:key_t m) (v:data_t)
//  : Lemma (requires (select m key = v))
//          (ensures (contains_value m v))
//  =
  //let p1 = (select m key = v) in
  //let p2 = (~(equal_selection_restricted m v 0 (count m))) in
  //let v = select m key in

  //Cl.move_requires_2 (lemma_contains_value #data_t) m v;
//  ()

//let lemma_contains_value_to_select (#data_t:eqtype) (m:t data_t) (v:data_t)
//  : Lemma (requires (contains_value m v))
//          (ensures exists (key:key_t m). (select m key = v))
//  =
//  ()

type contained_data_t (#data_t:eqtype) (m:t data_t) = x:data_t{contains_value m x}

let lemma_contained_data (#data_t:eqtype) (m:t data_t) (v:contained_data_t m)
  : Lemma ((En.ensured_predicate m.fallback v) /\ (not (is_empty m))) =
  ()

(* Note: 해당 함수의 해당 requires 는 꼭 존재해야 한다. *)
(*
private let rec last_key_agg' (#data_t:eqtype) (m:t data_t) (v:contained_data_t m) (desending_key:key_t m)
  : Pure (key_t m)
      (requires (equal_selection_restricted m v (desending_key+1) (count m)))
      (ensures fun r -> (equal_selection_restricted m v (r+1) (count m)) /\
                        ~(equal_selection_restricted m v 0 (r+1)) /\
                        (equal_selection m v r))
      (decreases desending_key)
  =
  match equal_selection m v desending_key with 
  | true -> desending_key
  | false -> last_key_agg' m v (desending_key-1)
*)
  
let last_key (#data_t:eqtype) (m:t data_t) (v:contained_data_t m)
  : Tot (key_t m)
  =
  Ls.desending_find 0 (count m) (equal_selection m v) |> Some?.v
  //last_key_agg' m v (max_key m)

(*
private let rec first_key_agg' (#data_t:eqtype) (m:t data_t) (v:contained_data_t m) (ascending_key:key_t m)
  : Pure (key_t m)
      (requires (equal_selection_restricted m v 0 ascending_key))
      (ensures fun r -> (equal_selection_restricted m v 0 r) /\
                        ~(equal_selection_restricted m v r (count m)) /\
                        (select m r = v))
      (decreases (max_key m) - ascending_key)
  =
  match select m ascending_key = v with 
  | true -> ascending_key
  | false -> first_key_agg' m v (ascending_key+1)
*)

let first_key (#data_t:eqtype) (m:t data_t) (v:contained_data_t m)
  : Tot (key_t m)
  =
  Ls.ascending_find 0 (count m) (equal_selection m v) |> Some?.v
  //first_key_agg' m v 0





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

let pop #data_t (m:ensured_t data_t) : Tot ((t data_t) & (key_value data_t)) =
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
