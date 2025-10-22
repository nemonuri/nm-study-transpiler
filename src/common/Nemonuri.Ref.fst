module Nemonuri.Ref

type t = {
  v: nat
}

let null = { v=0 }
let is_null (ref:t) : Tot bool = ref.v = 0

module Enp = Nemonuri.Ensured.Premise

instance ensured_premise_t : Enp.t t =
  {
    fallback = null
  }

type ensured_t = Enp.ensured t
