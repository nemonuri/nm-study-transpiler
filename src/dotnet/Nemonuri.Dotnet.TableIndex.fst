module Nemonuri.Dotnet.TableIndex

(* https://github.com/dotnet/runtime/blob/main/src/libraries/System.Reflection.Metadata/src/System/Reflection/Metadata/Ecma335/TableIndex.cs *)

type t =
| Module
| TypeRef
| TypeDef
| FieldPtr
| Field
| MethodPtr
| MethodDef
| ParamPtr
| Param
| InterfaceImpl
| MemberRef
| Constant
| CustomAttribute
| FieldMarshal
| DeclSecurity
| ClassLayout
| FieldLayout
| StandAloneSig
| EventMap
| EventPtr
| Event
| PropertyMap
| PropertyPtr
| Property
| MethodSemantics
| MethodImpl
| ModuleRef
| TypeSpec
| ImplMap
| FieldRva
| EncLog
| EncMap
| Assembly
| AssemblyProcessor
| AssemblyOS
| AssemblyRef
| AssemblyRefProcessor
| AssemblyRefOS
| File
| ExportedType
| ManifestResource
| NestedClass
| GenericParam
| MethodSpec
| GenericParamConstraint

// debug tables:
| Document
| MethodDebugInformation
| LocalScope
| LocalVariable
| LocalConstant
| ImportScope
| StateMachineMethod
| CustomDebugInformation
