module Nemonuri.Dotnet.TypeDefOrRef

module Ht = Nemonuri.Dotnet.HandleType
module H = Nemonuri.Dotnet.Handle

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.23.2.8-typedeforreforspecencoded.md *)

type t = 
| TypeDef: v:(H.explicit_t Ht.TypeDef) -> t
| TypeRef: v:(H.explicit_t Ht.TypeRef) -> t

//module Nemonuri.Dotnet.TypeDefOrRefOrSpec
