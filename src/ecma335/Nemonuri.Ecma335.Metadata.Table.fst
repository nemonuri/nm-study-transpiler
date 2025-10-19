module Nemonuri.Ecma335.Metadata.Table

module M = Nemonuri.Ecma335.Metadata
module S = FStar.Set

open FStar.Tactics.Typeclasses

class tablelike (id_t:eqtype) (data_t:Type) =
{
  id_set : S.set id_t;
  get_data : x:id_t{S.mem x id_set} -> data_t
}
