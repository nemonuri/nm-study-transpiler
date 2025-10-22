module Nemonuri.Bijective.IndexMap

module I = FStar.IntegerIntervals
module ISet = Nemonuri.IndexSet
module IMap = Nemonuri.IndexMap
//open FStar.Bijection { ( =~ ) }
//module B = FStar.Bijection
module Seq = FStar.Seq.Base
module List = FStar.List.Tot

let bijective_index_map_predicate (#data_t:eqtype) (m:IMap.t data_t) =
  m |> IMap.to_seq |> Seq.seq_to_list |> List.noRepeats

type t (data_t:eqtype) = x:IMap.t data_t{bijective_index_map_predicate x}

//let index_of 

//let lemma_bijective_index_map 
