module Nemonuri.Ecma335.Metadata.TableSchema
module M = Nemonuri.Ecma335.Metadata
module Te = Nemonuri.Ecma335.Metadata.TableEntry
module Ter = Nemonuri.Ecma335.Metadata.TableEntry.Refinement
module Heap = Nemonuri.Ecma335.Metadata.Heap

//--- module ---
(* https://github.com/stakx/ecma-335/blob/master/docs/ii.22.30-module_0x00.md *)

(*
   Todo:
   1. The Module table shall contain one and only one row [ERROR]
*)

(* The Module table has the following columns: *)
noeq
type module_schema = {

  string_heap: Heap.string_heap;
  guid_heap: Heap.guid_heap;
  (* - Name (an index into the String heap) *)
  (* 
     2. Name shall index a non-empty string. 
        This string should match exactly any corresponding ModuleRef.Name string that resolves to this module. [ERROR] 
  *)
  name: x:Ter.string_heap_index{not (Te.is_null x) && not (Heap.is_indexing_empty_string string_heap x)};

  (* - Mvid (an index into the Guid heap; simply a Guid used to distinguish between two versions of the same module) *)
  mvid: x:Ter.guid_heap_index{not (Te.is_null x) && not (Heap.is_indexing_null_guid guid_heap x)};
}
//---|

//--- typeref ---
(* https://github.com/stakx/ecma-335/blob/master/docs/ii.22.38-typeref-0x01.md *)
(*
   Todo:
   6. There shall be no duplicate rows, where a duplicate has the same ResolutionScope, TypeName and TypeNamespace [ERROR]
*)

(* The TypeRef table has the following columns: *)
noeq
type typeref_schema = {

  string_heap: Heap.string_heap;
  (* 
     - ResolutionScope (an index into a Module, ModuleRef, AssemblyRef or TypeRef table, or null; 
       more precisely, a ResolutionScope coded index) 
  *)
  (* Note: Can ResolutionScope be `null`? *)
  (* 1.iii a Module token, if the target type is defined in the current module – this should not occur in a CLI ("compressed metadata") module [WARNING] *)
  resolution_scope: option (x:M.resolution_scope{x <> M.ResolutionScopeModule});

  (* 2. TypeName shall index a non-empty string in the String heap [ERROR] *)
  type_name: x:Ter.string_heap_index{not (Te.is_null x) && not (Heap.is_indexing_empty_string string_heap x)};

  (* 3. TypeNamespace can be null, or non-null *)
  (* 4. If non-null, TypeNamespace shall index a non-empty string in the String heap [ERROR] *)
  type_namespace: x:Ter.string_heap_index{Te.is_null x || not (Heap.is_indexing_empty_string string_heap x)}
}

//---|