module Nemonuri.String

module U32 = FStar.UInt32
module L = FStar.List.Tot

let t = list U32.t

let rec equal (str1:t) (str2:t) : Tot bool =
  match (str1, str2) with
  | (hd1::tl1, hd2::tl2) -> equal tl1 tl2
  | ([], []) -> true
  | _ -> false
