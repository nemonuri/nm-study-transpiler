module Nemonuri.ControlFlow.IOperation

open FStar.Tactics.Typeclasses

(* https://github.com/FStarLang/FStar/blob/master/ulib/FStar.Pervasives.fsti *)
(* https://fstar-lang.org/tutorial/book/part4/part4_pure.html *)
type act_t (state_t result_t:Type) = state_t -> Tot (result_t & state_t)
type pre_t (state_t:Type) = state_t -> Type0
type post_t (state_t result_t:Type) = state_t -> result_t -> state_t -> Type0
type wp_t (state_t result_t:Type) = (post_t state_t result_t) -> Tot (pre_t state_t)


(* https://learn.microsoft.com/en-us/dotnet/api/microsoft.codeanalysis.ioperation?view=roslyn-dotnet-4.13.0 *)
class t (state_t result_t:Type) = {
  act: act_t state_t result_t;
  pre: pre_t state_t;
  post: post_t state_t result_t;
}



//let a = STATE_h state_t 

