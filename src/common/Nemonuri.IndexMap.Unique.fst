module Nemonuri.IndexMap.Unique

open Nemonuri.IndexMap
//module Ui = Nemonuri.Unique.IntegerIntervals
module Lu = Nemonuri.LinearUnique
module Ls = Nemonuri.LinearSearch
module Cl = FStar.Classical
open FStar.FunctionalExtensionality { (^->) }
module F = FStar.FunctionalExtensionality

let is_unique_in 
  (#data_t:eqtype) (m:t data_t) (v:contained_data_t m) 
  (imin:key_t m) (emax:key_or_count_t m{emax >= imin})
  : Tot bool =
  Lu.try_unique imin emax (equal_selection m v) |> Some?

let unique_data_predicate (#data_t:eqtype) (m:t data_t) (v:contained_data_t m) : Tot bool =
  is_unique_in m v 0 (count m)
  //(last_key m v) = (first_key m v)

let lemma_unique_data_predicate (#data_t:eqtype) (m:t data_t) (v:contained_data_t m) (witness:key_t m)
  : Lemma 
      (requires (equal_selection m v witness))
      (ensures (unique_data_predicate m v) <==>
               (Lu.predicate_is_linear_unique 0 (count m) (equal_selection m v) witness))
  =
  Lu.lemma_linear_unique 0 (count m) (equal_selection m v) witness

type unique_data_t (#data_t:eqtype) (m:t data_t) = x:contained_data_t m{unique_data_predicate m x}


let unique_key_predicate (#data_t:eqtype) (m:t data_t) (key:key_t m) : Tot bool =
  select m key |> unique_data_predicate m

let lemma_unique_key_predicate (#data_t:eqtype) (m:t data_t) (key:key_t m)
  : Lemma ((unique_key_predicate m key) <==> 
           (Lu.predicate_is_linear_unique 0 (count m) (equal_selection_key m key) key))
  =
  let pl = (unique_key_predicate m key) in
  let pr = (Lu.predicate_is_linear_unique 0 (count m) (equal_selection_key m key) key) in
  let v = select m key in
  let lemma_pl_to_pr' () : Lemma (pl ==> pr) =
    assert (equal_selection m v key);
    lemma_unique_data_predicate m v key
  in
  (* Note: 이게 왜 바로 증명이 되냐;; 나중에 내가 납득할 수 있도록 증명 해 봐야지. *)
  let lemma_pr_to_pl' () : Lemma (pr ==> pl) =
    //let f_t = (key_t m) ^-> Type0 in
    //let tm1: f_t = F.on (key_t m) (equal_selection_key m key) in
    //let tm2: f_t = F.on (key_t m) (equal_selection m v) in
    //assert (F.feq #(key_t m) #(fun _ -> Type0) tm1 tm2);
    //let tm3: f_t = F.on (key_t m) (Lu.predicate_is_linear_unique 0 (count m) tm1) in
    //let tm4: f_t = F.on (key_t m) (Lu.predicate_is_linear_unique 0 (count m) tm2) in
    //assert (F.feq #(key_t m) #(fun _ -> Type0) tm3 tm4);
    //assert (Lu.predicate_is_linear_unique 0 (count m) tm2 key);
    //assert (equal_selection m v key);
    let open FStar.Stubs.Tactics.V2.Builtins in (
      assert True by (dump "dumped!")
    );
    lemma_unique_data_predicate m v key
  in
  lemma_pl_to_pr' ();
  lemma_pr_to_pl' ()

type unique_key_t (#data_t:eqtype) (m:t data_t) = x:key_t m{unique_key_predicate m x}

let _ = assert True by (
  let open FStar.Tactics.V2 in (
    norm_term [delta] (`lemma_unique_key_predicate) |> term_to_string |> print
  )
)

(*
let is_max_selection_not_equal_in 
  (#data_t:eqtype) (m:t data_t)
  (imin:key_t m) (max:key_t m{max > imin})
  : Tot bool =
  let v = select m max in
  Ls.desending_find imin max (equal_selection m v) |> None?

let is_distinct (#data_t:eqtype) (m:t data_t)
  : Tot bool =
  match (count m) < 2 with | true -> true
  | false -> 
  let counterexample' (x:key_t m{x > 0}) : Tot bool =
    not (is_max_selection_not_equal_in m 0 x)
  in
  Ls.ascending_find 1 (max_key m) counterexample' |> None?

let lemma_is_distinct (#data_t:eqtype) (m:t data_t)
  : Lemma ((is_distinct m) <==> (forall (x:key_t m). (unique_key_predicate m x)))
  =
  admit ()
*)

let map_is_distinct (#data_t:eqtype) (map:t data_t)
  : Tot Type0 =
  forall (x1:key_t map). 
  forall (x2:key_t map{x2 < x1}). 
    ~(equal_selection_key map x1 x2)


let lemma_map_is_distinct (#data_t:eqtype) (m:t data_t)
  : Lemma ((map_is_distinct m) <==> (forall (x:key_t m). (unique_key_predicate m x)))
  =
  let pl = (map_is_distinct m) in
  let pr = (forall (x:key_t m). (unique_key_predicate m x)) in
  let pr1 = (forall (x:key_t m). (Lu.predicate_is_linear_unique 0 (count m) (equal_selection_key m x) x)) in
  let pl1 = (forall (x1 x2:key_t m). (x1 <> x2) ==> ~(equal_selection_key m x1 x2)) in
  let lemma_pr_eq_pr1' () : Lemma (pr <==> pr1) =
    Cl.forall_intro (lemma_unique_key_predicate m)
  in
  let lemma_pl_eq_pl1' () : Lemma (pl <==> pl1) =
    (* Note: 이건 당연히 쉽게 증명 될 것이다. *)
    assert (pl1 ==> pl);
    let lemma_pl_to_pl1' () : Lemma (requires pl) (ensures pl1) =
      (* Note: 
         - 이런 꼴의 증명 방식, 나중에 많이 쓰일 것 같은데.
         - 필요할 때 일반화 해야지. *)
      let lemma_pl_to_pl1'' (x1 x2:key_t m) 
        : Lemma (requires x1 <> x2) (ensures ~(equal_selection_key m x1 x2)) =
        match x1 < x2 with
        | true -> assert (~(equal_selection_key m x2 x1))
        | false -> assert (~(equal_selection_key m x1 x2))
      in
      Cl.move_requires_2 lemma_pl_to_pl1'' |> Cl.forall_intro_2
    in
    Cl.move_requires lemma_pl_to_pl1' ()
  in
  lemma_pr_eq_pr1' ();
  lemma_pl_eq_pl1' ()
