module Nemonuri.Refinement.Tot

open FStar.FunctionalExtensionality

noeq
type t (a:eqtype) = { predicate: a ^-> bool }

let equal (#a:eqtype) (r1:t a) (r2:t a) = feq r1.predicate r2.predicate

let refine (#a:eqtype) (r:t a) : Tot eqtype = x:a{r.predicate x}
