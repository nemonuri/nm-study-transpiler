#light "off"
module SimplePrintf
type arg =
| Bool
| Int
| Char
| String


let uu___is_Bool : arg  ->  Prims.bool = (fun ( projectee  :  arg ) -> (match (projectee) with
| Bool -> begin
true
end
| uu___ -> begin
false
end))


let uu___is_Int : arg  ->  Prims.bool = (fun ( projectee  :  arg ) -> (match (projectee) with
| Int -> begin
true
end
| uu___ -> begin
false
end))


let uu___is_Char : arg  ->  Prims.bool = (fun ( projectee  :  arg ) -> (match (projectee) with
| Char -> begin
true
end
| uu___ -> begin
false
end))


let uu___is_String : arg  ->  Prims.bool = (fun ( projectee  :  arg ) -> (match (projectee) with
| String -> begin
true
end
| uu___ -> begin
false
end))

type dir =
| Lit of FStar_String.char
| Arg of arg


let uu___is_Lit : dir  ->  Prims.bool = (fun ( projectee  :  dir ) -> (match (projectee) with
| Lit (_0) -> begin
true
end
| uu___ -> begin
false
end))


let __proj__Lit__item___0 : dir  ->  FStar_String.char = (fun ( projectee  :  dir ) -> (match (projectee) with
| Lit (_0) -> begin
_0
end))


let uu___is_Arg : dir  ->  Prims.bool = (fun ( projectee  :  dir ) -> (match (projectee) with
| Arg (_0) -> begin
true
end
| uu___ -> begin
false
end))


let __proj__Arg__item___0 : dir  ->  arg = (fun ( projectee  :  dir ) -> (match (projectee) with
| Arg (_0) -> begin
_0
end))


type arg_type =
obj


type dir_type =
obj


let rec string_of_dirs : dir Prims.list  ->  (Prims.string  ->  Prims.string)  ->  obj = (fun ( ds  :  dir Prims.list ) ( k  :  Prims.string  ->  Prims.string ) -> (match (ds) with
| [] -> begin
(box (k ""))
end
| (Lit (c))::ds' -> begin
(box (string_of_dirs ds' (fun ( res  :  Prims.string ) -> (k (Prims.strcat (FStar_String.string_of_char c) res)))))
end
| (Arg (a))::ds' -> begin
(box (fun ( x  :  obj ) -> (string_of_dirs ds' (fun ( res  :  Prims.string ) -> (Prims.strcat (k (match (a) with
| Bool -> begin
(Prims.unsafe_coerce (box (Prims.string_of_bool (Prims.unsafe_coerce x))))
end
| Int -> begin
(Prims.unsafe_coerce (box (Prims.string_of_int (Prims.unsafe_coerce x))))
end
| Char -> begin
(Prims.unsafe_coerce (box (FStar_String.string_of_char (Prims.unsafe_coerce x))))
end
| String -> begin
(Prims.unsafe_coerce (box x))
end)) res)))))
end))


let example1 : Prims.string = (Prims.unsafe_coerce ((fun ( uu___1  :  obj ) ( uu___  :  obj ) -> ((Prims.unsafe_coerce (string_of_dirs ((Arg (Int))::(Arg (String))::[]) (fun ( s  :  Prims.string ) -> s))) uu___1 uu___)) (Prims.unsafe_coerce (Prims.parse_int "42")) (Prims.unsafe_coerce " answer")))


let add_dir : dir  ->  dir Prims.list FStar_Pervasives_Native.option  ->  dir Prims.list FStar_Pervasives_Native.option = (fun ( d  :  dir ) ( ods  :  dir Prims.list FStar_Pervasives_Native.option ) -> (match (ods) with
| FStar_Pervasives_Native.None -> begin
FStar_Pervasives_Native.None
end
| FStar_Pervasives_Native.Some (ds) -> begin
FStar_Pervasives_Native.Some ((d)::ds)
end))


let rec parse_format_pure : FStar_String.char Prims.list  ->  dir Prims.list FStar_Pervasives_Native.option = (fun ( s  :  FStar_String.char Prims.list ) -> (match (s) with
| [] -> begin
FStar_Pervasives_Native.Some ([])
end
| ('%')::[] -> begin
FStar_Pervasives_Native.None
end
| ('%')::(c)::s' -> begin
(match (c) with
| '%' -> begin
(add_dir (Lit ('%')) (parse_format_pure s'))
end
| 'b' -> begin
(add_dir (Arg (Bool)) (parse_format_pure s'))
end
| 'd' -> begin
(add_dir (Arg (Int)) (parse_format_pure s'))
end
| 'c' -> begin
(add_dir (Arg (Char)) (parse_format_pure s'))
end
| 's' -> begin
(add_dir (Arg (String)) (parse_format_pure s'))
end
| uu___ -> begin
FStar_Pervasives_Native.None
end)
end
| (c)::s' -> begin
(add_dir (Lit (c)) (parse_format_pure s'))
end))


let parse_format_string : Prims.string  ->  dir Prims.list FStar_Pervasives_Native.option = (fun ( s  :  Prims.string ) -> (parse_format_pure (FStar_String.list_of_string s)))


type valid_format_string =
Prims.string


let sprintf : Prims.string  ->  obj = (fun ( s  :  Prims.string ) -> (string_of_dirs (FStar_Pervasives_Native.__proj__Some__item__v (parse_format_string s)) (fun ( s1  :  Prims.string ) -> s1)))


let test : unit  ->  Prims.string = (fun ( uu___  :  unit ) -> ((fun ( uu___  :  unit ) -> (Prims.unsafe_coerce ((fun ( uu___3  :  obj ) ( uu___2  :  obj ) ( uu___1  :  obj ) -> ((Prims.unsafe_coerce (sprintf "%d: Hello %s, sprintf %s")) uu___3 uu___2 uu___1)) (Prims.unsafe_coerce (Prims.parse_int "0")) (Prims.unsafe_coerce "#fstar-hackery") (Prims.unsafe_coerce "works!")))) uu___))




