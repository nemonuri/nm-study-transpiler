module Nemonuri.Natural.Distinct

module Lu = Nemonuri.LinearUnique
module Ls = Nemonuri.LinearSearch
module Cl = FStar.Classical
open FStar.Class.Eq { deq, eq }

open FStar.Tactics.Typeclasses

(* Note: cod 는 codomain 의 줄임말 *)

type selector_t (cod_t:Type) = nat -> Tot cod_t

let selector_is_distinct 
  (#cod_t:Type) {| d : deq cod_t |} (s:selector_t cod_t)
  : Tot Type0 =
  forall (n1 n2:nat). (eq #cod_t #d (s n1) (s n2)) ==> (n1 = n2)

let selector_is_distinct_half
  (#cod_t:Type) {| d : deq cod_t |} (s:selector_t cod_t)
  : Tot Type0 =
  forall (n1:nat).
  forall (n2:nat{n2 < n1}).
    not (eq #cod_t #d (s n1) (s n2))

type distinct_selector_t (cod_t:Type) {| d : deq cod_t |} = x:selector_t cod_t{selector_is_distinct x}

//let lemma_selector_is_distinct

//type inverse_selector_t (cod_t:Type) = cod_t -> nat
let inverse_distinct_selector_predicate
  (#cod_t:Type) {| d : deq cod_t |} 
  (s:distinct_selector_t cod_t)
  (inv_s:cod_t -> nat)
  : Tot Type0 =
  forall (n:nat). (inv_s (s n)) = n

let codomain_refiner_predicate
  (#cod_t:Type) {| d : deq cod_t |}
  (s:selector_t cod_t)
  (refiner:cod_t -> bool)
  : Tot Type0 =
  forall (cod:cod_t). 
    (refiner cod) <==> (exists (n:nat). (eq #cod_t #d cod (s n)))


