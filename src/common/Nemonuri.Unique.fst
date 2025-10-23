module Nemonuri.Unique

(*
   Uniqueness quantification
   - https://en.wikipedia.org/wiki/Uniqueness_quantification
*)

let singleton_predicate (#dom_t:eqtype) (refiner:dom_t -> Tot bool) =
  exists (x:dom_t). (forall (y:dom_t). (refiner y) <==> (y = x))

type singleton_t (dom_t:eqtype) = p:(dom_t -> Tot bool){singleton_predicate p}


let intro_singleton 
  (#dom_t:eqtype) (refiner:dom_t -> Tot bool) (w:dom_t)
  : Pure (singleton_t dom_t)
    (requires (forall (w1:dom_t). (refiner w1) <==> (w1 = w)))
    (ensures fun _ -> true)
  =
  refiner

let intro_singleton2
  (#dom_t:eqtype) (refiner:dom_t -> Tot bool) (w:dom_t)
  : Pure (singleton_t dom_t)
    (requires (forall (w1 w2:dom_t). ((refiner w1) /\ (refiner w2)) ==> (w1 = w2)) /\ (refiner w))
    (ensures fun _ -> true)
  =
  refiner

//let unique_predicate (#dom_t:eqtype) (singleton:singleton_t dom_t) (witness:dom_t) : Tot bool = singleton witness

type witness_t (#dom_t:eqtype) (singleton:singleton_t dom_t) = x:dom_t{singleton x}

noeq
type t (dom_t:eqtype) = {
  singleton: singleton_t dom_t;
  witness: witness_t singleton
}

let intro_unique
  (#dom_t:eqtype) (refiner:dom_t -> Tot bool) (w:dom_t)
  : Pure (t dom_t)
    (requires (forall (w1:dom_t). (refiner w1) <==> (w1 = w)))
    (ensures fun _ -> true)
  =
  {
    singleton = intro_singleton refiner w;
    witness = w
  }

let intro_unique2
  (#dom_t:eqtype) (refiner:dom_t -> Tot bool) (w:dom_t)
  : Pure (t dom_t)
    (requires (forall (w1 w2:dom_t). ((refiner w1) /\ (refiner w2)) ==> (w1 = w2)) /\ (refiner w))
    (ensures fun _ -> true)
  =
  {
    singleton = intro_singleton2 refiner w;
    witness = w
  }
