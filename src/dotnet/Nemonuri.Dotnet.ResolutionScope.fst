module Nemonuri.Dotnet.ResolutionScope

module Ht = Nemonuri.Dotnet.HandleType
module H = Nemonuri.Dotnet.Handle

(* https://github.com/dotnet/runtime/blob/main/src/libraries/System.Reflection.Metadata/src/System/Reflection/Metadata/Internal/ResolutionScopeTag.cs *)

type t =
| Module: (H.explicit_t Ht.Module) -> t
| ModuleRef: (H.explicit_t Ht.ModuleRef) -> t
| AssemblyRef: (H.explicit_t Ht.AssemblyRef) -> t
| TypeRef: (H.explicit_t Ht.TypeRef) -> t
