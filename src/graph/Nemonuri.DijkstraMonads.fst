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
let bind_wp (#result1_t #result2_t:eqtype) (#state_t:eqtype) (ts:ts_t)
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

open FStar.Monotonic.Pure

// uncurried state monad representation 
(* Note: 'Type' 보다 'Effect' 가 사실상 더 상위 타입이구나... *)
//effect t (result_t:eqtype) (state_t:eqtype) (ts:ts_t) (wp:wp_t state_t ts result_t) (pre_state:state_t) =
//  PURE ((ts result_t) & state_t) (as_pure_wp (wp pre_state))

//type result_type_factory_t (op_expr_t:eqtype) = op_expr_t -> eqtype
type op_to_post_t (result_t op_expr_t state_t:eqtype) (ts:ts_t) // (rtf:result_type_factory_t op_expr_t) = 
  =
  op_expr_t -> Tot (post_t state_t ts result_t)

type arrow_t 
  (result_t #op_expr_t #state_t:eqtype) (#ts:ts_t) 
  (op_to_post:op_to_post_t result_t op_expr_t state_t ts) =
  (pre_state:state_t) -> (op_expr:op_expr_t) -> (wp:wp_t state_t ts result_t) 
    -> Tot (r:((ts result_t) & state_t){wp pre_state (op_to_post op_expr)})
  //{FStar.Classical.impl_intro_tot (wp pre_state r)}
  //PURE ((ts result_t) & state_t) (as_pure_wp (wp pre_state))

type post_factory_t (state_t:eqtype) (ts:ts_t) (result_t:eqtype) = state_t -> post_t state_t ts result_t
let to_post_factory (state_t:eqtype) (ts:ts_t) (result_t:eqtype) 
                    (source:state_t -> (ts result_t) -> state_t -> Tot Type0)
  : Tot (post_factory_t state_t ts result_t) =
  fun (state:state_t) (r:(ts result_t) & state_t) -> source state (fst r) (snd r)

type hoare_t 
  (result_t op_expr_t state_t:eqtype) (ts:ts_t) 
  (pre:pre_t state_t) (post_factory:post_factory_t state_t ts result_t)
  =
  (pre_state:state_t) -> (op_expr:op_expr_t) -> 
    Pure ((ts result_t) & state_t) (pre pre_state) (fun r -> post_factory pre_state r)

(*
noeq
type t (state_t:eqtype) (ts:ts_t) = {
  return_wp: return_wp_t state_t ts;
  bind_wp: bind_wp_t state_t ts;
}
*)
