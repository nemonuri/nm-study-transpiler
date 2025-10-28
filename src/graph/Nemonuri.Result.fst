module Nemonuri.Result

type t (normal_t handleable_t fatal_t:eqtype) =
| Normal of normal_t
| Handleable of handleable_t
| Fatal of fatal_t
