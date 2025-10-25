module Nemonuri.Bijective.IndexMap.Bijection

open Nemonuri.Bijective.IndexMap
open Nemonuri.IndexMap { key_t,  contained_data_t, ensured_data_t }
open Nemonuri.IndexMap.Unique { map_is_distinct, unique_key_predicate, unique_data_predicate, lemma_map_is_distinct,
                                unique_key_t, unique_data_t }
open FStar.Bijection { (=~) }
module B = FStar.Bijection

let lemma_select_and_unique_key #data_t (m:t data_t) (key:unique_key_t m)
  : Lemma (unique_key m (select m key) == key) = ()
let lemma_unique_key_and_select #data_t (m:t data_t) (v:unique_data_t m)
  : Lemma (select m (unique_key m v) == v) = ()

type bijection_t #data_t (m:t data_t) = (unique_key_t m) =~ (unique_data_t m)

let to_bijection #data_t (m:t data_t)
  : Tot (bijection_t m) =
  {
    right = select m;
    left = unique_key m;
    left_right = lemma_select_and_unique_key m;
    right_left = lemma_unique_key_and_select m;
  }