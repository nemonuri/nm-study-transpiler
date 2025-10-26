module Nemonuri.Dotnet.Signature

module Cc = Nemonuri.Dotnet.CallingConvention
module TypeDefOrRef = Nemonuri.Dotnet.TypeDefOrRef
module L = FStar.List.Tot

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.23.2-blobs-and-signatures.md *)
(* https://github.com/dotnet/runtime/blob/main/src/libraries/System.Linq.Expressions/tests/ILReader/SigParser.cs *)

(*
        Sig ::= MethodDefSig | MethodRefSig | StandAloneMethodSig | FieldSig | PropertySig | LocalVarSig

        MethodDefSig ::= [[HASTHIS] [EXPLICITTHIS]] (DEFAULT|VARARG|GENERIC GenParamCount) ParamCount RetType Param*

        MethodRefSig ::= [[HASTHIS] [EXPLICITTHIS]] VARARG ParamCount RetType Param* [SENTINEL Param+]

        StandAloneMethodSig ::=  [[HASTHIS] [EXPLICITTHIS]] (DEFAULT|VARARG|C|STDCALL|THISCALL|FASTCALL)
                            ParamCount RetType Param* [SENTINEL Param+]

        FieldSig ::= FIELD CustomMod* Type

        PropertySig ::= PROPERTY [HASTHIS] ParamCount CustomMod* Type Param*

        LocalVarSig ::= LOCAL_SIG Count (TYPEDBYREF | ([CustomMod] [Constraint])* [BYREF] Type)+


        -------------

        CustomMod ::= ( CMOD_OPT | CMOD_REQD ) ( TypeDefEncoded | TypeRefEncoded )

        Constraint ::= #define ELEMENT_TYPE_PINNED

        Param ::= CustomMod* ( TYPEDBYREF | [BYREF] Type )

        RetType ::= CustomMod* ( VOID | TYPEDBYREF | [BYREF] Type )

        Type ::= ( BOOLEAN | CHAR | I1 | U1 | U2 | U2 | I4 | U4 | I8 | U8 | R4 | R8 | I | U |
                        | VALUETYPE TypeDefOrRefEncoded
                        | CLASS TypeDefOrRefEncoded
                        | STRING
                        | OBJECT
                        | PTR CustomMod* VOID
                        | PTR CustomMod* Type
                        | FNPTR MethodDefSig
                        | FNPTR MethodRefSig
                        | ARRAY Type ArrayShape
                        | SZARRAY CustomMod* Type
                        | GENERICINST (CLASS | VALUETYPE) TypeDefOrRefEncoded GenArgCount Type*
                        | VAR Number
                        | MVAR Number

        ArrayShape ::= Rank NumSizes Size* NumLoBounds LoBound*

        TypeDefOrRefEncoded ::= TypeDefEncoded | TypeRefEncoded
        TypeDefEncoded ::= 32-bit-3-part-encoding-for-typedefs-and-typerefs
        TypeRefEncoded ::= 32-bit-3-part-encoding-for-typedefs-and-typerefs

        ParamCount ::= 29-bit-encoded-integer
        GenArgCount ::= 29-bit-encoded-integer
        Count ::= 29-bit-encoded-integer
        Rank ::= 29-bit-encoded-integer
        NumSizes ::= 29-bit-encoded-integer
        Size ::= 29-bit-encoded-integer
        NumLoBounds ::= 29-bit-encoded-integer
        LoBounds ::= 29-bit-encoded-integer
        Number ::= 29-bit-encoded-integer
*)

type custom_mod_kind_t =
| Optional
| Required

type custom_mod_t = {
  kind: custom_mod_kind_t;
  type_def_or_ref: TypeDefOrRef.t;
}

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.23.2.13-arrayshape.md *)
type array_shape_t = {
  rank: pos;
  //num_sizes: nat;
  size: list nat; //{L.length x = num_sizes};
  //num_lo_bounds: nat;
  lo_bound: list nat; //{L.length x = num_lo_bounds};
}

let num_sizes (array_shape:array_shape_t) = array_shape.size |> L.length
let num_lo_bounds (array_shape:array_shape_t) = array_shape.lo_bound |> L.length


type method_def_sig_union_t = 
| MethodDefDefault
| MethodDefVarArg
| MethodDefGeneric: gen_param_count:nat -> method_def_sig_union_t

type class_or_value_type_t =
| Class
| ValueType


(* https://github.com/dotnet/runtime/blob/main/docs/design/specs/Ecma-335-Augments.md *)
type type_t =
| Boolean | Char | I1 | U1 | I2 | U2 | I4 | U4 | I8 | U8 | R4 | R8 | I | U
| ClassOrValueType: class_or_value_type_t -> TypeDefOrRef.t -> type_t
| String
| Object
| Ptr: (list custom_mod_t) -> (option type_t) -> type_t
| FnPtr: fn_ptr_method_def_or_ref_sig_t -> type_t
| Array: type_t -> array_shape_t -> type_t
| SzArray: (list custom_mod_t) -> type_t -> type_t
| GenericInst: class_or_value_type_t -> TypeDefOrRef.t -> (* GenArgCount: nat -> *) _:(x:list type_t{L.length x > 0}) -> type_t
| Var: nat -> type_t
| MVar: nat -> type_t

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.23.2.11-rettype.md *)
and ret_type_union_t =
| RetTypeVoid
| RetTypeTypedByRef
| RetTypeByRefType: bool -> type_t -> ret_type_union_t

and ret_type_t = {
 custom_mod: (list custom_mod_t);
 union: ret_type_union_t;
}

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.23.2.10-param.md *)
and param_union_t =
| ParamTypedByRef
| ParamByRefType: bool -> type_t -> param_union_t

and param_t = {
 custom_mod: (list custom_mod_t);
 union: param_union_t;
}

and method_def_sig_t = {
  attribute: Cc.attribute_t;
  union: method_def_sig_union_t;
  param_count: nat;
  ret_type: ret_type_t;
  param: list param_t
}

and method_ref_sig_t = {
  attribute: Cc.attribute_t;
  param_count: nat;
  ret_type: ret_type_t;
  param: list param_t;
  sentinel_param: list param_t;
}

and fn_ptr_method_def_or_ref_sig_t =
| FnPtrMethodDefSig: method_def_sig_t -> fn_ptr_method_def_or_ref_sig_t
| FnPtrMethodRefSig: method_ref_sig_t -> fn_ptr_method_def_or_ref_sig_t


type stand_alone_method_sig_union_t =
| StandAloneMethodSigDefault
| StandAloneMethodSigVarArg
| StandAloneMethodSigC
| StandAloneMethodSigStdCall
| StandAloneMethodSigThisCall
| StandAloneMethodSigFastCall

type stand_alone_method_sig_t = {
  attribute: Cc.attribute_t;
  union: stand_alone_method_sig_t;
  param_count: nat;
  ret_type: ret_type_t;
  param: list param_t;
  sentinel_param: list param_t;
}


type field_sig_t = {
 custom_mod: (list custom_mod_t);
 field_type: type_t;
}


type property_sig_t = {
  has_this: bool;
  param_count: nat;
  custom_mod: (list custom_mod_t);
  property_type: type_t;
  param: list param_t;
}


type local_var_union_sig_t =
| LocalVarTypedByRef
| LocalVarByRefType: (list (custom_mod_t & bool)) -> bool -> type_t -> local_var_union_sig_t

type local_var_sig_t = {
  count: nat;
  union: (x:list local_var_union_sig_t{L.length x > 0});
}


type t =
| MethodDefSig: method_def_sig_t -> t
| MethodRefSig: method_ref_sig_t -> t
| StandAloneMethodSig: stand_alone_method_sig_t -> t
| FieldSig: field_sig_t -> t
| PropertySig: property_sig_t -> t
| LocalVarSig: local_var_sig_t -> t

