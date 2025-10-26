module Nemonuri.Dotnet.CallingConvention

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.15.3-calling-convention.md *)

type unrefined_attribute_t = {
  has_this: bool;
  explicit_this: bool;
}

let attribute_predicate (att:unrefined_attribute_t) : Tot bool = 
  if att.explicit_this then att.has_this else true

type attribute_t = x:unrefined_attribute_t{attribute_predicate x}

(* https://learn.microsoft.com/en-us/dotnet/api/system.reflection.callingconventions?view=net-9.0 *)
type managed_call_kind_t = 
| Default
| VarArg

(* https://learn.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.callingconvention?view=net-9.0 *)
type unmanaged_call_kind_t = 
| Cdecl
| StdCall
| ThisCall
| FastCall
