module Nemonuri.Dotnet.FieldAttribute

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.23.1.5-flags-for-fields-fieldattributes.md *)
(* https://github.com/dotnet/runtime/blob/main/src/libraries/System.Private.CoreLib/src/System/Reflection/FieldAttributes.cs *)

type field_access_t =
| PrivateScope  // Member not referenceable.
| Private  // Accessible only by the parent type.
| FamANDAssem  // Accessible by sub-types only in this Assembly.
| Assembly  // Accessibly by anyone in the Assembly.
| Family  // Accessible only by type and sub-types.
| FamORAssem  // Accessibly by sub-types anywhere, plus anyone in assembly.
| Public  // Accessibly by anyone who has visibility to this scope.

type t = {
  field_access: field_access_t;
  static: bool;
  init_only: bool;
  literal: bool;
  special_name: bool;
  pinvoke_impl: bool;
  re_special_name: bool;
  has_field_marshal: bool;
  has_default: bool;
  has_field_rva: bool;
}

