module Nemonuri.Ecma335.Metadata.Table

module M = Nemonuri.Ecma335.Metadata

open FStar.Tactics.Typeclasses

class tablelike (id_t:eqtype) (data_t:Type) =
{
  id_predicate : id_t -> Tot bool;
  get_data : x:id_t{id_predicate x} -> data_t
}

let has_id (#id_t:eqtype) (#data_t:Type) (table: tablelike id_t data_t) (id:id_t) : Tot bool =
  table.id_predicate id
