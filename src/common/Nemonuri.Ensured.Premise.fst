module Nemonuri.Ensured.Premise

module En = Nemonuri.Ensured
open FStar.Tactics.Typeclasses

class t (data_t:Type) = {
  fallback: data_t
}

let ensured_predicate #data_t {| premise:t data_t |} (data:data_t) = En.ensured_predicate premise.fallback data

type ensured (data_t:Type) {| premise:t data_t |} = En.t premise.fallback


