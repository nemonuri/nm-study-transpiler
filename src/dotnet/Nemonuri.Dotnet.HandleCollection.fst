module Nemonuri.Dotnet.HandleCollection

module Ht = Nemonuri.Dotnet.HandleType
module L = FStar.List.Tot

(* https://github.com/dotnet/runtime/blob/main/src/libraries/System.Reflection.Metadata/src/System/Reflection/Metadata/TypeSystem/HandleCollections.TypeSystem.cs *)

type t = {
  kind : Ht.t;
  first_row_id : nat;
  count : nat;
}