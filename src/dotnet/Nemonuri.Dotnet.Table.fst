module Nemonuri.Dotnet.Table

module Ht = Nemonuri.Dotnet.HandleType
module H = Nemonuri.Dotnet.Handle
module Rs = Nemonuri.Dotnet.ResolutionScope
module TypeAttribute = Nemonuri.Dotnet.TypeAttribute
module TypeDefOrRefOrSpec = Nemonuri.Dotnet.TypeDefOrRefOrSpec
module FieldAttribute = Nemonuri.Dotnet.FieldAttribute

(* https://github.com/dotnet/runtime/blob/main/src/libraries/System.Reflection.Metadata/src/System/Reflection/Metadata/Internal/Tables.cs *)

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.22.30-module_0x00.md *)
type module_t = {
  generation: nat;
  name: H.explicit_t Ht.String;
  mvid: H.explicit_t Ht.Guid;
  enc_id: H.explicit_t Ht.Guid;
  enc_base_id: H.explicit_t Ht.Guid;
}

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.22.38-typeref-0x01.md *)
type type_ref_t = {
  resolution_scope: Rs.t;
  name: H.explicit_t Ht.String;
  namespace: H.explicit_t Ht.String;
}

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.22.37-typedef-0x02.md *)
type type_def_t = {
  flag: TypeAttribute.t;
  namespace_definition: H.explicit_t Ht.Namespace;
  namespace: H.explicit_t Ht.String;
  name: H.explicit_t Ht.String;
  extend: TypeDefOrRefOrSpec.t;
  field_start: H.explicit_t Ht.FieldDef;
  method_start: H.explicit_t Ht.MethodDef;
}

(* https://github.com/stakx/ecma-335/blob/master/docs/ii.22.15-field-0x04.md *)
type field_t = {
  name: H.explicit_t Ht.String;
  flag: FieldAttribute.t;
  signature: H.explicit_t Ht.Blob;
}

type method_t = {
  param_start: H.explicit_t Ht.ParamDef;
  signature: H.explicit_t Ht.Blob;
  rva: nat;
  name: H.explicit_t Ht.String;
  
}
