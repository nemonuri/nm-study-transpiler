module Nemonuri.DijkstraMonads

module R = FStar.Reflection.V2
open FStar.Tactics.Typeclasses

(* https://github.com/FStarLang/FStar/blob/master/examples/oplss2021/OPLSS2021.DijkstraMonads.fst *)
(* https://fstar-lang.org/papers/mumon/ *)
(* https://github.com/FStarLang/FStar/blob/master/examples/dsls/bool_refinement/BoolRefinement.fst *)

type type_selector_t = Type -> Type

type post_t (state_t:eqtype) (ts:type_selector_t) (result_t:eqtype) = (ts result_t) -> state_t -> Tot Type0
type pre_t (state_t:eqtype) = state_t -> Tot Type0

private type wp_raw_t (state_t:eqtype) (ts:type_selector_t) (result_t:eqtype) = (post_t state_t ts result_t) -> Tot (pre_t state_t)

// Premute arguments of 'wp_raw_t', to make monad binder form!
type wp_t (state_t:eqtype) (ts:type_selector_t) (result_t:eqtype) = 
     state_t -> (post_t state_t ts result_t) -> Tot Type0


type return_wp_t (state_t:eqtype) (ts:type_selector_t) = (result_t:eqtype) -> (result:ts result_t) -> (wp_t state_t ts result_t)
type bind_wp_t (state_t:eqtype) (ts:type_selector_t) = 
  (result1_t:eqtype) -> (result2_t:eqtype) -> (wp1:wp_t state_t ts result1_t) -> (wp2:result1_t -> wp_t state_t ts result2_t) -> (wp_t state_t ts result2_t)

noeq
type t (state_t:eqtype) (ts:type_selector_t) = {
  return_wp: return_wp_t state_t ts;
  bind_wp: bind_wp_t state_t ts;
}


//type repr_t (result_t:eqtype) (state_t:eqtype) (ts:type_selector_t) (wp:wp_t state_t ts result_t) = 
//  (state:state_t) -> (forall )


//type arrow_t (state_t source_t result_t:Type) = state_t -> source_t -> result_t -> state_t

//let compute #state_t 
