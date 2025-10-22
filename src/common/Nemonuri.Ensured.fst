module Nemonuri.Ensured


let ensured_predicate (#data_t:Type) (fallback:data_t) (data:data_t) = fallback =!= data

type t (#data_t:Type) (fallback:data_t) = x:data_t{ensured_predicate fallback x}

//type from_premise (data_t:Type) {| p : premise data_t |} = 