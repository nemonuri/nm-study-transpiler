module Nemonuri.Dotnet.AssemblyLoadContext

(*
   Reference :
   - https://github.com/dotnet/runtime/blob/main/src/libraries/System.Private.CoreLib/src/System/Runtime/Loader/AssemblyLoadContext.cs
   - https://github.com/dotnet/runtime/blob/main/src/coreclr/nativeaot/System.Private.CoreLib/src/System/Runtime/Loader/AssemblyLoadContext.NativeAot.cs
*)

type assembly_t = unit

type t = {
  loaded_assemblies : list assembly_t
}