module Nemonuri.Dotnet.TableMask

module I = Nemonuri.Dotnet.TableIndex
module L = FStar.List.Tot

(* https://github.com/dotnet/runtime/blob/main/src/libraries/System.Reflection.Metadata/src/System/Reflection/Metadata/Internal/MetadataFlags.cs *)

type t =
| PtrTables 
| EncTables 
| TypeSystemTables 
| DebugTables 
| AllTables 
| ValidPortablePdbExternalTables 


let get_stair (m:t) : Tot nat =
  match m with
  | PtrTables | EncTables | DebugTables -> 0
  | TypeSystemTables -> 1
  | AllTables | ValidPortablePdbExternalTables  -> 2


 let rec masks (m:t) (i:I.t)
  : Tot bool (decreases (get_stair m)) =
  match m with
  | PtrTables -> (L.mem i [I.FieldPtr;I.MethodPtr;I.ParamPtr;I.EventPtr;I.PropertyPtr])
  | EncTables -> (L.mem i [I.EncLog; I.EncMap])
  | TypeSystemTables -> 
      (masks PtrTables i) || (masks EncTables i) ||
      (L.mem i [ I.Module; I.TypeRef; I.TypeDef; I.Field; I.MethodDef; I.Param; I.InterfaceImpl; I.MemberRef; I.Constant; I.CustomAttribute; I.FieldMarshal; I.DeclSecurity; I.ClassLayout; I.FieldLayout; I.StandAloneSig; I.EventMap; I.Event; I.PropertyMap; I.Property; I.MethodSemantics; I.MethodImpl; I.ModuleRef; I.TypeSpec; I.ImplMap; I.FieldRva; I.Assembly; I.AssemblyRef; I.File; I.ExportedType; I.ManifestResource; I.NestedClass; I.GenericParam; I.MethodSpec; I.GenericParamConstraint])
  | DebugTables -> (L.mem i [I.Document; I.MethodDebugInformation; I.LocalScope; I.LocalVariable; I.LocalConstant; I.ImportScope; I.StateMachineMethod; I.CustomDebugInformation])
  | AllTables -> (masks TypeSystemTables i) || (masks DebugTables i)
  | ValidPortablePdbExternalTables -> (masks TypeSystemTables i) && (not (masks PtrTables i)) && (not (masks EncTables i))
      