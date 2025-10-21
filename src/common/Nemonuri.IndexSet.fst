module Nemonuri.IndexSet

module I = FStar.IntegerIntervals
module FSet = FStar.FiniteSet.Base
open FStar.FiniteSet.Ambient

type t_unrefined (n: nat) = FSet.set (I.under n)

(* `t_unrefined n` 타입의 정의로부터   
   `(FSet.mem x s) ==> (I.interval_condition 0 n x)` 가 유도되므로,
   특성함수 식에 `<==>` 대신 `==>` 를 명세해도 의미가 같다. *)
let index_set_predicate #n (s:t_unrefined n) =
  forall (x:int). (I.interval_condition 0 n x) ==> (FSet.mem x s)

type t (n:nat) = x:t_unrefined n {index_set_predicate x}

let empty : t 0 = FSet.emptyset #(I.under 0)

(*
let push #n (s:t n) : Tot (t (n+1)) =
  match n with
  | 0 -> FSet.singleton 
*)

module Iv = Nemonuri.IndexSet.Invariant

let to_invariant #n (s:t n) : Tot Iv.t = Iv.create n

//let to_variant (s:Iv.t) : Tot (t s.count) = s.set //...하....포기다, 포기!



