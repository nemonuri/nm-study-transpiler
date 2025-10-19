module Nemonuri.Ref

type t = {
  v: nat
}

let is_null (ref:t) : Tot bool = ref.v = 0
