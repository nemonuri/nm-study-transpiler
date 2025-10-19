module Nemonuri.Ecma335.Metadata.ModuleTable
module M = Nemonuri.Ecma335.Metadata
module Te = Nemonuri.Ecma335.Metadata.TableEntry
module Ts = Nemonuri.Ecma335.Metadata.TableSchema
module L = FStar.List.Tot

(* 1. The Module table shall contain one and only one row [ERROR] *)
noeq
type t = {
  v: list Ts.module_schema;
  only_one_row: squash (L.length v == 1)
}

let create (ms:Ts.module_schema) : Tot t =
  {
    v = [ms];
    only_one_row = ();
  }
