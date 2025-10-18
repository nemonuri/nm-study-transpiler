module Nemonuri.Stack

module F = FStar.FunctionalExtensionality

let arrow (a: Type) (b: (a -> Type)) = x: a -> Tot (b x)
