module Nemonuri.IMonad

open FStar.Tactics.Typeclasses

(* https://github.com/FStarLang/FStar/blob/master/src/class/FStarC.Class.Monad.fsti *)

type type_selector_t = Type -> Type

class t (ts: type_selector_t) = {
   return : #a:Type -> a -> ts a;
   bind   : #a:Type -> #b:Type -> ts a -> (a -> ts b) -> ts b
}

(* Aliases. Need to declare a very precise type for them. *)
let ( let! ) : #m:type_selector_t -> {| t m |} -> #a:Type -> #b:Type -> m a -> (a -> m b) -> m b = bind
let ( >>=  ) : #m:type_selector_t -> {| t m |} -> #a:Type -> #b:Type -> m a -> (a -> m b) -> m b = bind

inline_for_extraction
let ( >=> ) #m {| t m |} #a #b #c
  (f : a -> m b) (g : b -> m c) :  a -> m c =
  fun x -> f x >>= g
