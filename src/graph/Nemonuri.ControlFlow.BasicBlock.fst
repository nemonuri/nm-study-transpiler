module Nemonuri.ControlFlow.BasicBlock

(* https://github.com/dotnet/roslyn/blob/main/src/Compilers/Core/Portable/Operations/BasicBlockKind.cs *)
type kind_t =
| Entry
| Exit
| Block
