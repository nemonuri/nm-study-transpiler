module Nemonuri.Ecma335.Metadata.TableSchema
module M = Nemonuri.Ecma335.Metadata
module Te = Nemonuri.Ecma335.Metadata.TableEntry
module Ter = Nemonuri.Ecma335.Metadata.TableEntry.Refinement

//--- module ---
(* https://github.com/stakx/ecma-335/blob/master/docs/ii.22.30-module_0x00.md *)

(*
   Todo:
   1. The Module table shall contain one and only one row [ERROR]
*)

(* The Module table has the following columns: *)
type module_schema = {

  (* - Name (an index into the String heap) *)
  (* 
     2. Name shall index a non-empty string. 
        This string should match exactly any corresponding ModuleRef.Name string that resolves to this module. [ERROR] 
  *)
  name: x:Te.string_heap_index{not (Te.is_null x) && not (Te.is_indexing_empty_string x)};

  (* - Mvid (an index into the Guid heap; simply a Guid used to distinguish between two versions of the same module) *)
  mvid: x:Te.guid_heap_index{not (Te.is_null x) && not (Te.is_indexing_null_guid x)};
}
//---|

//--- typeref ---
(* https://github.com/stakx/ecma-335/blob/master/docs/ii.22.38-typeref-0x01.md *)
(*
   Todo:
   6. There shall be no duplicate rows, where a duplicate has the same ResolutionScope, TypeName and TypeNamespace [ERROR]
*)

(* The TypeRef table has the following columns: *)
type typeref_schema = {

  (* 
     - ResolutionScope (an index into a Module, ModuleRef, AssemblyRef or TypeRef table, or null; 
       more precisely, a ResolutionScope coded index) 
  *)
  (* Note: Can ResolutionScope be `null`? *)
  (* 1.iii a Module token, if the target type is defined in the current module – this should not occur in a CLI ("compressed metadata") module [WARNING] *)
  resolution_scope: option (x:M.resolution_scope{x <> M.ResolutionScopeModule});

  (* 2. TypeName shall index a non-empty string in the String heap [ERROR] *)
  type_name: x:Te.string_heap_index{not (Te.is_null x) && not (Te.is_indexing_empty_string x)};

  (* 3. TypeNamespace can be null, or non-null *)
  (* 4. If non-null, TypeNamespace shall index a non-empty string in the String heap [ERROR] *)
  type_namespace: x:Te.string_heap_index{Te.is_null x || not (Te.is_indexing_empty_string x)}
}

//---|