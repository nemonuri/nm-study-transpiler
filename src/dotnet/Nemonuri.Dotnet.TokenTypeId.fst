module Nemonuri.Dotnet.TokenTypeId

module L = FStar.List.Tot

(* https://github.com/dotnet/runtime/blob/main/src/libraries/System.Reflection.Metadata/src/System/Reflection/Metadata/Internal/MetadataFlags.cs *)

type t =
| Module
| TypeRef
| TypeDef
| FieldDef
| MethodDef
| ParamDef
| InterfaceImpl
| MemberRef
| Constant
| CustomAttribute
| DeclSecurity
| Signature
| EventMap
| Event
| PropertyMap
| Property
| MethodSemantics
| MethodImpl
| ModuleRef
| TypeSpec
| Assembly
| AssemblyRef
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
| AsyncMethod
| CustomDebugInformation

| UserString

