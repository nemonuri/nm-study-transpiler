module Nemonuri.IndexMap.Unique

open Nemonuri.IndexMap
module Cl = FStar.Classical

let unique_data_predicate (#data_t:eqtype) (m:t data_t) (v:contained_data_t m) : Tot bool =
  (last_key m v) = (first_key m v)

type unique_data_t (#data_t:eqtype) (m:t data_t) = x:contained_data_t m{unique_data_predicate m x}

//let lemma_unique_data2 (#data_t:eqtype) (m:t data_t) (v:unique_data_t m)
//  : Lemma ()

let lemma_unique_data (#data_t:eqtype) (m:t data_t) (k:key_t m) (v:contained_data_t m)
  : Lemma ((unique_data_predicate m v) ==> ((v = select m k) <==> (last_key m v = k)))
  =
  match (unique_data_predicate m v) with | false -> () | true ->
  let uk = last_key m v in
  assert (~(interval_does_not_contain_value m v 0 (count m)));
  assert (interval_does_not_contain_value m v (uk+1) (count m));
  assert (interval_does_not_contain_value m v 0 uk);
  assert (v = select m uk)
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
