module Nemonuri.Ecma335.Metadata.Table

module M = Nemonuri.Ecma335.Metadata
module Rf = Nemonuri.Refinement.Tot

open FStar.Tactics.Typeclasses

class tablelike (id_t:eqtype) (data_t:Type) =
{
  id_domain : Rf.t id_t;
  get_data : (Rf.refine id_domain) -> data_t
}

let has_id (#id_t:eqtype) (#data_t:Type) (table: tablelike id_t data_t) (id:id_t) : Tot bool =
  table.id_domain.predicate id
