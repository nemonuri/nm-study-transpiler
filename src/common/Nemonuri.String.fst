module Nemonuri.String

open FStar.Char
module L = FStar.List.Tot

let t = list char

let empty : t = []

module Enp = Nemonuri.Ensured.Premise

instance ensured_premise_t : Enp.t t =
  {
    fallback = empty
  }

type ensured_t = Enp.ensured t
