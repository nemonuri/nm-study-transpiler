module Nemonuri.Ecma335.Metadata

(*
   https://github.com/stakx/ecma-335/blob/master/docs/ii.22-metadata-logical-format-tables.md
*)

(* Metadata is stored in two kinds of structure: tables (arrays of records) and heaps. *)
type storage_structure_kind =
  | Table
  | Heap

(* There are four heaps in any module: String, Blob, Userstring, and Guid. *)
type heap_kind =
  | String
  | Blob
  | Userstring
  | Guid

(* Each entry in each column of each table is either a constant or an index. *)
type table_entry_kind =
  | Constant
  | Index

(* Constants are either literal values, or, more commonly, bitmasks. *)
type constant_kind = 
  | Literal
  | Bitmask

(*  
   Most bitmasks (they are almost all called Flags) are 2 bytes wide (e.g., the Flags column in the Field table), 
   but there are a few that are 4 bytes (e.g., the Flags column in the TypeDef table).
*)
type bitmask_wide = x:int{x = 2 || x = 4}

(* Each index is either 2 or 4 bytes wide. *)
type index_wide = bitmask_wide

(* The index points into the same or another table, or into one of the four heaps. *)
type index_point_kind =
   | PointSameTable
   | PointAnotherTable
   | PointHeap

let is_null (i:nat) = i = 0

(* 
   There are two kinds of columns that index a metadata table.
   - Simple 
   - Coded 
*)
type table_column_kind =
  | Simple
  | Coded
