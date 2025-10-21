module Nemonuri.IndexedStackMap

module I = FStar.IntegerIntervals
module FMap = FStar.FiniteMap.Base
module FSet = FStar.FiniteSet.Base
open FStar.FiniteSet.Ambient
open FStar.FiniteMap.Ambient
module F = FStar.FunctionalExtensionality

private let rec create_indices_set_agg (n: nat) (idx:I.under (n+1)) :
  Tot (FSet.set (I.under n))
      (decreases n-idx) =
  match idx = n with
  | true -> FSet.emptyset #(I.under n)
  | false -> FSet.insert idx (create_indices_set_agg n (idx+1))

type indices_set (n:nat) = FSet.set (I.under n)

private let interval_condition' (n:nat) (x y:int) (v:I.under n) = I.interval_condition x y v

private let lemma_create_indices_set_agg_feq (n: nat) (idx:I.under (n+1)) (e:I.under n) :
  Lemma (ensures (idx <= e) <==> (FSet.mem e (create_indices_set_agg n idx)))
  =
  let lhs = (idx <= e) in
  let rhs = (FSet.mem e (create_indices_set_agg n idx)) in
  let lemma_l_to_r' () : Lemma (lhs ==> rhs) =
    admit ()
  in
  let lemma_r_to_l' () : Lemma (rhs ==> lhs) =
    admit ()
  in
  lemma_l_to_r' ();
  lemma_r_to_l' ()

let create_indices_set (n:nat) : Tot (indices_set n) = create_indices_set_agg n 0

let lemma_create_indices_set_subset (n: nat) (idx:I.under n) (idx2:nat{idx2 <= idx})
  : Lemma (ensures FSet.subset (create_indices_set_agg n idx) (create_indices_set_agg n idx2))
          //(decreases idx - idx2)
  =
  let (s1, s2) = ((create_indices_set_agg n idx), (create_indices_set_agg n idx2)) in
  match idx = idx2 with
  | true -> assert (s1 == s2)
  | false ->
  //let lemma_create_indices_set_mem2' 
  FStar.Classical.forall_intro (lemma_create_indices_set_agg_feq n idx);
  assert (forall (x:I.under n). (idx <= x) <==> (FSet.mem x s1));
  FStar.Classical.forall_intro (lemma_create_indices_set_agg_feq n idx2);
  assert (forall (x:I.under n). (idx2 <= x) <==> (FSet.mem x s2));
  assert (forall (x:I.under n). (idx <= x) ==> (idx2 <= x));
  assert (forall (x:I.under n). (FSet.mem x s1) ==> (FSet.mem x s2))
  //assert (forall (x:I.under n). ((idx <= x) ==> (idx2 <= x)) <==> ((FSet.mem x s1) ==> (FSet.mem x s2)));
  //assume (forall (x:nat{idx <= x && x < n}). FSet.mem x (create_indices_set_agg n idx2))
  //assert (forall (x:nat{idx <= x && x < n}). FSet.mem x (create_indices_set_agg n idx) ==> FSet.mem x (create_indices_set_agg n idx2))


let lemma_create_indices_set_mem (n: nat) (idx:I.under n)
  : Lemma (ensures FSet.mem idx (create_indices_set n))
  =
  assert (n > 0);
  assert (FSet.mem idx (create_indices_set_agg n idx));
  let lemma_create_indices_set_subset' (idx2: nat{idx2 <= idx}) : 
    Lemma (ensures FSet.subset (create_indices_set_agg n idx) (create_indices_set_agg n idx2)) =
    lemma_create_indices_set_subset n idx idx2
  in
  lemma_create_indices_set_subset' 0


type indices_map (n:nat) (data_t:Type) = FMap.map (I.under n) data_t

let indexed_stack_map_predicate (#n:nat) (#data_t:Type) (m:indices_map n data_t) = FSet.equal (FMap.domain m) (create_indices_set n)

let lemma_create_indices_set_zero () : Lemma (ensures FSet.equal (FSet.emptyset) (create_indices_set 0)) = ()

type t (n:nat) (data_t:Type) = x:indices_map n data_t {indexed_stack_map_predicate x}

let empty (data_t:Type) : Tot (t 0 data_t) = FMap.emptymap #(I.under 0) #data_t

//--- mem property ---
let lemma_mem #n #data_t (m:t n data_t) (idx:I.under n)
  : Lemma (ensures FMap.mem idx m)
  =
  //--- Goal: `FSet.mem idx (FMap.domain m)` ---
  let lemma_mem_domain' () : Lemma (FSet.mem idx (FMap.domain m)) =
    //--- Goal: `FSet.mem idx (create_indices_set n)` ---
    let lemma_create_indices_set_mem' () : Lemma (FSet.mem idx (create_indices_set n)) =
      lemma_create_indices_set_mem n idx
    in
    //---|
    lemma_create_indices_set_mem' ()
  in
  //---|
  lemma_mem_domain' ()


//---|

//--- invariant ---|

module Iv = Nemonuri.IndexedStackMap.Invariant

private let rec to_invarient_indices_map_agg #n #data_t (m:t n data_t) (idx:I.under (n+1)) :
  Tot (Iv.indices_map data_t)
      (decreases n-idx) =
  match idx = n with
  | true -> FMap.emptymap #int #data_t
  | false ->
  let key = idx <: int in
  lemma_mem m idx;
  let value = FMap.lookup idx m in
  FMap.insert key value (to_invarient_indices_map_agg m (idx+1))

let to_invarient_indices_map #n #data_t (m:t n data_t) 
  : Tot (Iv.indices_map data_t) =
  to_invarient_indices_map_agg m 0

let to_invarient #n #data_t (m:t n data_t)
  : Tot (Iv.t data_t) =
  {
    count = n;
    map = to_invarient_indices_map m
  }


//---|


//let grow_map #n #data_t (m:FMap.map (I.under n) data_t) : Tot (FMap.map (I.under (n+1)) data_t) =


//let push #n #data_t (m:t n data_t) (d:data_t) : Tot (t (n+1) data_t) =
//  FMap.insert (n+1) d m
