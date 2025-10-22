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

let select #data_t (m:t data_t) (key:int{contains m key}) : Tot data_t = Map.sel m.map key

let lemma_select #data_t (m:t data_t) (key:int{contains m key})
  : Lemma (select m key =!= m.fallback) =
  ()

let interval_does_not_contain_value (#data_t:eqtype) (m:t data_t) (v:data_t) (min:int) (max:int) = 
  (forall (x:int).{:pattern (contains m x)\/(I.interval_condition min max x)\/(select m x = v)} 
    (contains m x) ==> (I.interval_condition min max x) ==> ~(select m x = v))

private let rec contains_value_agg' (#data_t:eqtype) (m:t data_t) (v:data_t) (cur_key:int) 
  : Pure bool 
      (requires (En.ensured_predicate m.fallback v) /\ (contains m cur_key) /\
                (interval_does_not_contain_value m v (cur_key+1) (count m))
                //(forall (x:int). (I.interval_condition (cur_key+1) (count m) x) ==> ~(select m x = v))
      )
      (ensures fun _ -> true)
      (decreases cur_key)
  =
  match select m cur_key = v with | true -> true 
  | false -> 
  match cur_key = 0 with | true -> false
  | false ->
  contains_value_agg' m v (cur_key-1)

private let lemma_contains_value_agg_result_is_false (#data_t:eqtype) (m:t data_t) (v:data_t) (cur_key:int) 
  : Lemma
      (requires (En.ensured_predicate m.fallback v) /\ (contains m cur_key) /\
                (interval_does_not_contain_value m v (cur_key+1) (count m)) /\
                ((contains_value_agg' m v cur_key) = false)
      )
      (ensures (interval_does_not_contain_value m v (cur_key) (count m)) /\
               ((cur_key > 0) ==> ((contains_value_agg' m v (cur_key-1)) = false))
      )
  =
  ()

private let lemma_contains_value_agg_result_is_false_forall (#data_t:eqtype) (m:t data_t) (v:data_t)
  : Lemma (ensures ((contains_value_agg' m v 0) /\ ((contains_value_agg' m v ((count m) - 1)) = false)) ==> 
            (interval_does_not_contain_value m v 0 (count m)))
    [SMTPat (interval_does_not_contain_value m v);SMTPat (contains_value_agg' m v)]
  =
  FStar.Classical.forall_intro (lemma_contains_value_agg_result_is_false m v)

private let rec lemma_contains_value_agg' (#data_t:eqtype) (m:t data_t) (v:data_t) (key_upper_bound:int) (ascending_key:int)
  : Lemma (requires (En.ensured_predicate m.fallback v) /\ (contains m key_upper_bound) /\
                    (interval_does_not_contain_value m v (key_upper_bound+1) (count m)) /\
                    (contains_value_agg' m v key_upper_bound) /\ (I.interval_condition 0 (key_upper_bound+1) ascending_key) /\
                    (interval_does_not_contain_value m v 0 ascending_key)
          )
          (ensures ~(interval_does_not_contain_value m v 0 (key_upper_bound+1)))
          (decreases key_upper_bound - ascending_key)
          [SMTPat (interval_does_not_contain_value m v)]
  =
  match key_upper_bound = ascending_key with 
  | true -> 
      assert (~(select m key_upper_bound = v) ==> (interval_does_not_contain_value m v 0 (count m)))
  | false ->
  match select m ascending_key = v with | true -> ()
  | false ->
  lemma_contains_value_agg' m v key_upper_bound (ascending_key+1)
  

(*
private let lemma_contains_value_agg' (#data_t:eqtype) (m:t data_t) (v:data_t) (key_upper_bound:int) (cur_key:int)
  : Lemma (requires (contains_value_agg' m v key_upper_bound) /\ 
                    (I.interval_condition 0 (key_upper_bound+1) cur_key) /\
                    (forall (x:int). (I.interval_condition 0 cur_key x) ==> (select m x <> v)))
          (ensures exists (x:int). (select m x = v))
  =
  ()
*)


let contains_value (#data_t:eqtype) (m:t data_t) (v:data_t) : Tot bool =
  match v = m.fallback with | true -> false 
  | false ->
  match (count m) > 0 with | false -> false 
  | true ->
  contains_value_agg' m v ((count m) - 1)

//let lemma_contains_value (#data_t:eqtype) (m:t data_t) (v:data_t)

(*
let lemma_contains_value (#data_t:eqtype) (m:t data_t) (v:data_t)
  : Ghost unit (requires (contains_value m v))
               (ensures fun _ -> exists (x:nat). (contains m x) /\ (select m x = v))
  =
  // assert (~(forall (x:nat). ~((contains m x) ==> (select m x = v))))
  let p = (fun (x:nat) -> (contains m x) ==> (select m x = v)) in
  assert (~(forall (x:nat). ~(p x)));
*)

(*
private let p'' (data_t:eqtype) (m:t data_t) (v:data_t) (cur_key:int) = (contains m cur_key) ==> ~(select m cur_key = v)

private let lemma_contains_value' (data_t:eqtype) (m:t data_t) (v:data_t)
  : Lemma (requires (contains_value m v) /\ (contains m cur_key) /\
                    ~(select m x = v))
*)

//let lemma_contains_value



private let rec last_key_agg' (#data_t:eqtype) (m:t data_t) (v:data_t) (cur_key:int)
  : Pure int
        (requires 
          (contains_value m v) /\ (contains m cur_key) /\
          (forall (x:int). (I.interval_condition (cur_key+1) (count m) x) ==> (select m x <> v))
        )
        (ensures fun key -> contains m key)
        (decreases cur_key)
  =
  //assert (I.interval_condition 0 (count m) cur_key);
  //assume (~(forall (x:nat). ((contains m x) ==> ~(select m x = v))));
  assume (exists (x:nat). (contains m x) /\ (select m x = v));
  //assert (exists (x:int{contains m x}). select m x = v);
  match select m cur_key = v with | true -> cur_key
  | false ->
  //match (count m) - 1 - cur_key = 0 with | true -> False
  //| false ->
  //assert (forall (x:nat). (I.interval_condition (cur_key) (count m) x) ==> (select m x <> v));
  //let lemma' (x:nat{I.interval_condition 0 cur_key x})
  //FStar.Classical.exists_intro_not_all_not (fun (x:int{I.interval_condition 0 cur_key x}) -> ~(select m x = v));
  //assert (cur_key > 0);
  //assert (contains_value_agg m v )
  last_key_agg' m v (cur_key-1)
  

(*
let first_index (#data_t:eqtype) (m:t data_t) (v:data_t{contains_value m v}) 
  : Tot (key:int{contains m key})
  =
*)


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
