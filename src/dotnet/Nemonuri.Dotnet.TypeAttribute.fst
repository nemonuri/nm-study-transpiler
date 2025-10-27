module Nemonuri.Dotnet.TypeAttribute

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.23.1.15-flags-for-types-typeattributes.md *)
(* https://github.com/dotnet/runtime/blob/main/src/libraries/System.Private.CoreLib/src/System/Reflection/TypeAttributes.cs *)
type visibility_t = 
  | NotPublic
  | Public
  | NestedPublic
  | NestedPrivate
  | NestedFamily
  | NestedAssembly
  | NestedFamANDAssem
  | NestedFamORAssem

type layout_t =
  | AutoLayout
  | SequentialLayout
  | ExplicitLayout
  | ExtendedLayout 

type class_semantic_t =
  | Class
  | Interface

type t = {
  visibility: visibility_t;
  layout: layout_t;
  semantic: class_semantic_t;
  abstract: bool;
  sealed: bool;
  special_name: bool;
  import: bool;
  before_field_init: bool;
  rt_special_name: bool;
  has_security: bool;
  //is_type_forwarder: bool;
}

