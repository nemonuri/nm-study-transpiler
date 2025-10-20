module Nemonuri.Ecma335.Metadata.Table

module M = Nemonuri.Ecma335.Metadata

open FStar.Tactics.Typeclasses

type refiner (e_t:eqtype) = e_t -> Tot bool

class maplike #id_t (rf:refiner id_t) (data_t:Type) = {
  get_data : x:id_t{rf x} -> data_t
}

noeq
type tablelike (id_t:eqtype) (data_t:Type) = {
  id_refiner : refiner id_t;
  get_data : x:id_t{id_refiner x} -> data_t
}

let convert_maplike_to_tablelike 
  #id_t (#rf:refiner id_t) #data_t (m:maplike rf data_t) : Tot (tablelike id_t data_t) =
  {
    id_refiner = rf;
    get_data = m.get_data
  }

let convert_tablelike_to_maplike
  #id_t #data_t (table:tablelike id_t data_t) : Tot (maplike table.id_refiner data_t) =
  {
    get_data = table.get_data
  }

(*
  이 방법을 통해, '타입 파라미터' 를 '타입 멤버' 로 변환할 수 있고, 그 역도 가능하다.
*)
let refiner_elem #id_t (#rf:refiner id_t) #data_t (m:maplike rf data_t) = convert_maplike_to_tablelike m
let refiner_intro #id_t #data_t (table:tablelike id_t data_t) = convert_tablelike_to_maplike table

//class tablelike (id_t:eqtype) (data_t:Type) (id_predicate:id_t -> Tot bool) =
//{
//  get_data : x:id_t{id_predicate x} -> data_t
//}

(*
class tablelike (id_t:eqtype) (data_t:Type) =
{
  id_predicate : id_t -> Tot bool;
  get_data : x:id_t{id_predicate x} -> data_t
}

let has_id (#id_t:eqtype) (#data_t:Type) (table: tablelike id_t data_t) (id:id_t) : Tot bool =
  table.id_predicate id
*)