module Nemonuri.DijkstraMonads

module R = FStar.Reflection.V2
include Nemonuri.IMonad { type_selector_t as ts_t, t as imonad_t }
open FStar.Tactics.Typeclasses

(* https://github.com/FStarLang/FStar/blob/master/examples/oplss2021/OPLSS2021.DijkstraMonads.fst *)
(* https://fstar-lang.org/papers/mumon/ *)
(* https://github.com/FStarLang/FStar/blob/master/examples/dsls/bool_refinement/BoolRefinement.fst *)


type post_t (state_t:eqtype) (ts:ts_t) (result_t:eqtype) = ((ts result_t) & state_t) -> Tot Type0
type pre_t (state_t:eqtype) = state_t -> Tot Type0

private type raw_wp_t (state_t:eqtype) (ts:ts_t) (result_t:eqtype) = (post_t state_t ts result_t) -> Tot (pre_t state_t)

// Premute arguments of 'raw_wp_t', to make monad binder form!
type unrefined_wp_t (state_t:eqtype) (ts:ts_t) (result_t:eqtype) = state_t -> (post_t state_t ts result_t) -> Tot Type0

let wp_is_monotonic #state_t #ts #result_t (wp:unrefined_wp_t state_t ts result_t) : Tot Type0 =
  forall (pre_state: state_t) (post1 post2: post_t state_t ts result_t).
                                                            //If post1 is stronger than post2
  (forall (maybe_result:ts result_t) (post_state: state_t). (post1 (maybe_result , post_state)) ==> (post2 (maybe_result , post_state)))
      //Then (wp pre_state post1) is stronger then (wp pre_state post2)
  ==> ((wp pre_state post1) ==> (wp pre_state post2))

type wp_t (state_t:eqtype) (ts:ts_t) (result_t:eqtype) = x:unrefined_wp_t state_t ts result_t{wp_is_monotonic x}


(* Note: 왜 Dijkstra Monad 의 멤버들은 모두 unfold 특성을 붙이는거지? *)
(* Note: return_wp 의 parameter 순서를, 이렇게 정하는 게 맞을까? *)
unfold
let return_wp (#result_t:eqtype) (#state_t:eqtype) (ts:ts_t) (m:imonad_t ts) (result:result_t) 
  : wp_t state_t ts result_t =
  (* Note: pre_state = post_state *)
  fun pre_state post -> post ((m.return result), pre_state)

(* Note:
   - wp(statement1;statement2, post) = wp1(statement1, wp2(statement2, post))
   - https://en.wikipedia.org/wiki/Predicate_transformer_semantics#Sequence *)
unfold
let bind_wp (#result1_t #result2_t:eqtype) (#state_t:eqtype) (ts:ts_t) (m:imonad_t ts)
            (wp1:wp_t state_t ts result1_t)
            (wp2_factory:ts result1_t -> wp_t state_t ts result2_t)
  : wp_t state_t ts result2_t =
  fun pre1_state post ->
    let post1: post_t state_t ts result1_t = 
      fun (maybe_result1, post1_state) -> 
        (* Note: post1_state = pre2_state *)
        (wp2_factory maybe_result1 post1_state post)
    in
    wp1 pre1_state post1
        
  //let post_factory: post_t state_t ts 
  //let outer_post: post_t state_t ts result1_t =
  //  fun (outer_maybe_result, post_state) -> 
  //    inner_wp_selector outer_maybe_result 
  //fun outer_pre_state inner_post ->
  //  outer_wp


//type bind_wp_t (state_t:eqtype) (ts:ts_t) = 
//  (result1_t:eqtype) -> (result2_t:eqtype) -> (wp1:wp_t state_t ts result1_t) -> (wp2:result1_t -> wp_t state_t ts result2_t) -> (wp_t state_t ts result2_t)

(*
noeq
type t (state_t:eqtype) (ts:ts_t) = {
  return_wp: return_wp_t state_t ts;
  bind_wp: bind_wp_t state_t ts;
}
*)

//type repr_t (result_t:eqtype) (state_t:eqtype) (ts:type_selector_t) (wp:wp_t state_t ts result_t) = 
//  (state:state_t) -> (forall )


//type arrow_t (state_t source_t result_t:Type) = state_t -> source_t -> result_t -> state_t

//let compute #state_t 
