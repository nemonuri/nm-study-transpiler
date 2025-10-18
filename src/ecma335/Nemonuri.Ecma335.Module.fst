module Nemonuri.Ecma335.Module
module Te = Nemonuri.Ecma335.Metadata.TableEntry

(*
 * https://github.com/stakx/ecma-335/blob/master/docs/ii.22.30-module_0x00.md
*)

type t = {
  name:Te.string_heap_index;
  mvid:Te.guid_heap_index
}
