module Nemonuri.IndexMap.Unique

open Nemonuri.IndexMap
module Ui = Nemonuri.Unique.IntegerIntervals
module Cl = FStar.Classical

let unique_data_predicate (#data_t:eqtype) (m:t data_t) (v:contained_data_t m) : Tot bool =
  (last_key m v) = (first_key m v)

type unique_data_t (#data_t:eqtype) (m:t data_t) = x:contained_data_t m{unique_data_predicate m x}

let data_to_prop (#data_t:eqtype) (m:t data_t) (v:unique_data_t m) =
  Ui.create_prop 
    0 (count m) (equal_selection m v) (last_key m v) () () (lemma_contains_value m v)

//let lemma_unique_data2 (#data_t:eqtype) (m:t data_t) (v:unique_data_t m)
//  : Lemma ()

let lemma_unique_data (#data_t:eqtype) (m:t data_t) (k:key_t m) (v:contained_data_t m)
  : Lemma ((unique_data_predicate m v) ==> ((equal_selection m v k) <==> (last_key m v = k)))
  =
  match (unique_data_predicate m v) with | false -> () | true ->
  assert (data_to_prop m v)
  (*
  let uk = last_key m v in
  assert (~(equal_selection_restricted m v 0 (count m)));
  assert (equal_selection_restricted m v (uk+1) (count m));
  assert (equal_selection_restricted m v 0 uk);
  assert (equal_selection m v uk)
  *)
  (*
  let pl = (v = select m k) in
  let pr = (last_key m v = k) in
  let lemma_l_to_r' () : Lemma (requires pl) (ensures pr) =
    assert (uk = k)
  in
  let lemma_r_to_l' () : Lemma (requires pr) (ensures pl) =
     ()
  in
  Cl.move_requires lemma_l_to_r' ();
  Cl.move_requires lemma_r_to_l' ()
  *)

let unique_key_predicate (#data_t:eqtype) (m:t data_t) (key:key_t m) : Tot bool =
  select m key |> unique_data_predicate m

type unique_key_t (#data_t:eqtype) (m:t data_t) = x:key_t m{unique_key_predicate m x}
