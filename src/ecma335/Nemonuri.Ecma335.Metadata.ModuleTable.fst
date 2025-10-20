module Nemonuri.Ecma335.Metadata.ModuleTable
module M = Nemonuri.Ecma335.Metadata
module Te = Nemonuri.Ecma335.Metadata.TableEntry
module Ter = Nemonuri.Ecma335.Metadata.TableEntry.Refinement
module Ts = Nemonuri.Ecma335.Metadata.TableSchema
module Table = Nemonuri.Ecma335.Metadata.Table

open FStar.Tactics.Typeclasses

(* 1. The Module table shall contain one and only one row [ERROR] *)
type t (p:Ts.premise) = {
  id: Ter.module_table_index;
  data: Ts.module_schema p
}

let maplike_module_table_refiner #p (mt:t p) (te:Te.t) : Tot bool = 
  Ter.module_table_index_predicate te && (te = mt.id)

instance maplike_module_table #p (mt:t p) : Table.maplike (maplike_module_table_refiner mt) (Ts.module_schema p) = {
  get_data = fun _ -> mt.data
}
