module Nemonuri.LinearUnique

module I = FStar.IntegerIntervals
module U = Nemonuri.Unique
open Nemonuri.LinearSearch


//--- unique ---

let try_unique 
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  : Tot (option (U.t (I.interval imin emax)))
  =
  match (ascending_find imin emax predicate, desending_find imin emax predicate) with
  | (Some va, Some vd) -> (
    match va = vd with
    | true -> Some (U.intro_unique predicate va)
    | false -> None )
  | ( None , None ) -> None

let try_unique_witness
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  : Tot (option (I.interval imin emax))
  =
  match try_unique imin emax predicate with
  | Some u -> Some u.witness
  | None -> None

let try_unique_some_post
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  (witness: I.interval imin emax)
  : Tot Type0 =
  (ascending_found_at imin emax predicate witness) /\
  (desending_found_at imin emax predicate witness)

let try_unique_post
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  (r:option (U.t (I.interval imin emax)))
  : Tot Type0 =
  ((None? r) <==> (
    let af = ascending_find imin emax predicate in
    let df = desending_find imin emax predicate in
    (None? af /\ None? df) \/ (Some?.v af <> Some?.v df)
  )) /\
  ((Some? r) ==> (
    let v = Some?.v r in
    try_unique_some_post imin emax predicate v.witness
    //(ascending_found_at imin emax predicate v.witness) /\
    //(desending_found_at imin emax predicate v.witness)
  ))

let lemma_try_unique
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  : Lemma (try_unique imin emax predicate |> try_unique_post imin emax predicate) =
  ()

let linear_unique_predicate
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  (witness: I.interval imin emax)
  : Tot Type0 =
  (not_found_in imin witness predicate) /\ 
  (not_found_in (witness+1) emax predicate) /\
  (predicate witness)

noeq
type unrefined_t = {
  imin: int;
  emax: int;
  predicate: predicate_t imin emax;
  witness: I.interval imin emax
}

type t = x:unrefined_t{linear_unique_predicate x.imin x.emax x.predicate x.witness}

let lemma_linear_unique_aux1
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  (witness: I.interval imin emax)
  : Lemma ((linear_unique_predicate imin emax predicate witness) <==>
           (try_unique_some_post imin emax predicate witness))
  =
  ()

let lemma_linear_unique_aux2
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  (witness: I.interval imin emax)
  : Lemma ((try_unique_some_post imin emax predicate witness) <==> 
           (try_unique_witness imin emax predicate = Some witness))
  =
  ()

let lemma_linear_unique
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  (witness: I.interval imin emax)
  : Lemma (
      let p1 = (linear_unique_predicate imin emax predicate witness) in
      let p2 = (try_unique_some_post imin emax predicate witness) in
      let p3 = (try_unique_witness imin emax predicate = Some witness) in
      (p1 <==> p2) /\ (p2 <==> p3))
  =
  lemma_linear_unique_aux1 imin emax predicate witness;
  lemma_linear_unique_aux2 imin emax predicate witness
//---|