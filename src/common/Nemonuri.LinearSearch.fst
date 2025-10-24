module Nemonuri.LinearSearch

module I = FStar.IntegerIntervals

type predicate_t (imin: int) (emax: int) = (I.interval imin emax) -> Tot bool

let not_found_in
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  : Tot Type0 =
  forall (x:int). 
    {:pattern (I.interval_condition imin emax x) \/ (predicate x)}
    (I.interval_condition imin emax x) ==> ~(predicate x)
  
let found_in
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  : Tot Type0 =
  ~(not_found_in imin emax predicate)

//--- asending ---
let ascending_found_at
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  (found_index: I.interval imin emax)
  : Tot Type0 =
  (not_found_in imin found_index predicate) /\ 
  (found_in found_index emax predicate) /\ (predicate found_index)

let ascending_find_post  
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  (r:option (I.interval imin emax))
  : Tot Type0 =
  ((None? r) <==> (not_found_in imin emax predicate)) /\
  ((Some? r) ==> (ascending_found_at imin emax predicate (Some?.v r)))

private let rec ascending_find_agg'
  (imin: int) (emax: int) (predicate: predicate_t imin emax) 
  (ascending_index: I.interval imin emax)
  : Pure (option (I.interval imin emax))
      (requires (not_found_in imin ascending_index predicate))
      (ensures fun r -> ascending_find_post imin emax predicate r)
      (decreases emax - ascending_index - 1)
  =
  match predicate ascending_index with | true -> Some ascending_index
  | false ->
  match ascending_index = emax - 1 with | true -> None
  | false ->
  ascending_find_agg' imin emax predicate (ascending_index+1)

let ascending_find
  (imin: int) (emax: int) (predicate: predicate_t imin emax)
  : Tot (r:(option (I.interval imin emax)){ascending_find_post imin emax predicate r})
  =
  match imin >= emax with 
  | true -> None
  | false -> ascending_find_agg' imin emax predicate imin
//---|

//--- desending ---
let desending_found_at
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  (found_index: I.interval imin emax)
  : Tot Type0 =
  (found_in imin (found_index+1) predicate) /\ 
  (not_found_in (found_index+1) emax predicate) /\ (predicate found_index)

let desending_find_post  
  (imin: int) (emax: int) 
  (predicate: predicate_t imin emax)
  (r:option (I.interval imin emax))
  : Tot Type0 =
  ((None? r) <==> (not_found_in imin emax predicate)) /\
  ((Some? r) ==> (desending_found_at imin emax predicate (Some?.v r)))

private let rec desending_find_agg'
  (imin: int) (emax: int) (predicate: predicate_t imin emax) 
  (desending_index: I.interval imin emax)
  : Pure (option (I.interval imin emax))
      (requires (not_found_in (desending_index+1) emax predicate))
      (ensures fun r -> desending_find_post imin emax predicate r)
      (decreases desending_index - imin)
  =
  match predicate desending_index with | true -> Some desending_index
  | false ->
  match desending_index = imin with | true -> None
  | false ->
  desending_find_agg' imin emax predicate (desending_index-1)

let desending_find
  (imin: int) (emax: int) (predicate: predicate_t imin emax)
  : Tot (r:(option (I.interval imin emax)){desending_find_post imin emax predicate r})
  =
  match imin >= emax with 
  | true -> None
  | false -> desending_find_agg' imin emax predicate (emax-1)
//---|

