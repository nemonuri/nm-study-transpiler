module Nemonuri.Dotnet.TypeDefOrRefOrSpec

module Ht = Nemonuri.Dotnet.HandleType
module H = Nemonuri.Dotnet.Handle

type t = 
| TypeDef: v:(H.explicit_t Ht.TypeDef) -> t
| TypeRef: v:(H.explicit_t Ht.TypeRef) -> t
| TypeSpec: v:(H.explicit_t Ht.TypeSpec) -> t
