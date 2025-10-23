module Nemonuri.Bijective.IndexMap

module I = FStar.IntegerIntervals
module ISet = Nemonuri.IndexSet
module IMap = Nemonuri.IndexMap
module Seq = FStar.Seq.Base
module List = FStar.List.Tot
module B = FStar.Bijection

let bijective_index_map_predicate (#data_t:eqtype) (m:IMap.t data_t) =
  m |> IMap.to_seq |> Seq.seq_to_list |> List.noRepeats

type t (data_t:eqtype) = x:IMap.t data_t{bijective_index_map_predicate x}

//let index_of 

//let lemma_bijective_index_map #data_t (m:t data_t)
//  : Lemma




type bijection_t #data_t (m:t data_t) = B.bijection (IMap.key_t m) (IMap.contained_data_t m)



(*
let to_bijection #data_t (m:t data_t)
  : Tot (bijection_t m) =
  {
    right = 
  }
*)