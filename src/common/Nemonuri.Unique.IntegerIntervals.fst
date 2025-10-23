module Nemonuri.Unique.IntegerIntervals

module U = Nemonuri.Unique
module I = FStar.IntegerIntervals

let is_restricted
  (imin: int) (emax: int) 
  (refiner: (I.interval imin emax) -> Tot bool)
  =
  forall (x:int). 
    {:pattern (I.interval_condition imin emax x) \/ (refiner x)}
    (I.interval_condition imin emax x) ==> ~(refiner x)

let is_exist
  (imin: int) (emax: int) 
  (refiner: (I.interval imin emax) -> Tot bool)
  =
  exists (x:int). 
    {:pattern (I.interval_condition imin emax x) \/ (refiner x)}
    (I.interval_condition imin emax x) /\ (refiner x)

noeq
type t = {
  imin: int;
  emax: int;
  refiner: (I.interval imin emax) -> Tot bool;
  witness: I.interval imin emax;
  lemma_min_restricted: squash (is_restricted imin witness refiner);
  lemma_max_restricted: squash (is_restricted (witness+1) emax refiner);
  lemma_exists: squash (is_exist imin emax refiner);
}

let lemma_unique (u:t)
  : Lemma ((U.singleton_predicate u.refiner) /\ (u.refiner u.witness)) =
  ()

let to_unique (u:t) = U.intro_unique u.refiner u.witness

let to_prop (u:t) : Tot Type0 =
  (is_restricted u.imin u.witness u.refiner) /\
  (is_restricted (u.witness+1) u.emax u.refiner) /\
  (is_exist u.imin u.emax u.refiner) /\
  (U.singleton_predicate u.refiner) /\ (u.refiner u.witness)

let create_prop
  (imin: int)
  (emax: int)
  (refiner: (I.interval imin emax) -> Tot bool)
  (witness: I.interval imin emax)
  (lemma_min_restricted: squash (is_restricted imin witness refiner))
  (lemma_max_restricted: squash (is_restricted (witness+1) emax refiner))
  (lemma_exists: squash (is_exist imin emax refiner))
  : Tot Type0 =
  to_prop {
    imin=imin; emax=emax; refiner=refiner; witness=witness;
    lemma_min_restricted=lemma_min_restricted;
    lemma_max_restricted=lemma_max_restricted;
    lemma_exists=lemma_exists;
  }
