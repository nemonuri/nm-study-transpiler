module Nemonuri.Ecma335.Metadata.TypeAttributes

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.23.1.15-flags-for-types-typeattributes.md *)
type visibility_kind = 
  | NotPublic
  | Public
  | NestedPublic
  | NestedPrivate
  | NestedFamily
  | NestedAssembly
  | NestedFamANDAssem
  | NestedFamORAssem

type layout_kind =
  | AutoLayout
  | SequentialLayout
  | ExplicitLayout

type semantic_kind =
  | Class
  | Interface

type t = {
  visibility: visibility_kind;
  layout: layout_kind;
  semantic: semantic_kind;
  abstract: bool;
  sealed: bool;
  special_name: bool;
  import: bool;
  before_field_init: bool;
  rt_special_name: bool;
  has_security: bool;
  is_type_forwarder: bool;
}


