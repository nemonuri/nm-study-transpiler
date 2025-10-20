module Nemonuri.IntegerIntervalMap.Under

//include FStar.IntegerIntervals { under as under_t }
module I = FStar.IntegerIntervals
module FMap = FStar.FiniteMap.Base
module FSet = FStar.FiniteSet.Base
module Seq = FStar.Seq.Base
module L = FStar.List.Tot

let indices_seq_predicate #n (s:Seq.seq (I.under n)) =
  Seq.length s = n /\
  (forall (k: I.under n). Seq.index s k = k)

let indices_list_predicate #n (l:list (I.under n)) =
  L.length l = n /\
  (forall (k: I.under n). L.index l k = k)

let create_indices_list (n: nat) =
  Seq.seq_to_list (I.indices_seq n)

module Seqp = FStar.Seq.Properties

let rec lemma_seq_to_list_index #n (s:Seq.seq (I.under n)) (l:list (I.under n)) (idx:I.under n) :
  Lemma (requires Seq.seq_to_list s = l /\ Seq.length s = n /\ (forall (k: I.under n). Seq.index s k = k))
        (ensures (L.index l idx = idx))
        (decreases (n-1-idx))
  =
  assert (Seq.length s = L.length l);
  match Seq.length s = 0 with
  | true -> () | false ->
  Seqp.lemma_index_is_nth s idx;
  assert (Seq.index s idx = L.index l idx);
  assert (Seq.index s idx = idx);
  match idx = n-1 with
  | true -> ()
  | false -> lemma_seq_to_list_index s l (idx+1)

let lemma_create_indices_list (n: nat) :
  Lemma (ensures indices_list_predicate (create_indices_list n)) =
  let l = create_indices_list n in
  let s = Seq.seq_of_list l in
  (* proof of
     `(forall (k: I.under n). L.index l k = k)` *)
  let aux (idx:I.under n) : 
    Lemma (ensures (L.index l idx = idx)) =
    lemma_seq_to_list_index s l idx
  in
  FStar.Classical.forall_intro aux



private let rec create_indices_set_agg (n: nat) (idx:I.under (n+1)) :
  Tot (FSet.set (I.under n))
      (decreases n-idx) =
  match idx = n with
  | true -> FSet.emptyset #(I.under n)
  | false -> FSet.insert idx (create_indices_set_agg n (idx+1))

let create_indices_set (n: nat) : Tot (FSet.set (I.under n)) =
  create_indices_set_agg n 0
    

