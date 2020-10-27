open Fun
open Ops
open Imp

(*

let rec translate_expr exp =
	match exp with
		| Cst(a) -> string_of_int a
		| Bool(b) -> begin
					 match b with
						| true -> "true"
						| false -> "false"
					 end
		| Var(str) -> str
		| Unop(op, e) -> begin
						 match op with
							| Ops.Minus -> "-" ^ (translate_expr e)
							| Ops.Not -> "!(" ^ (translate_expr e) ^ ")"
						 end
		| Binop(op, e1, e2) -> Imp.Binop
		
		| Tpl(lexp) -> 	begin 
						   let taille = List.length lexp in 
						   let tab = Imp.array_create taille in
						   let rec setTab l acc =
						   match l with
						   | h::t -> Imp.array_set tab acc (Imp.expression h); setTab t (acc+1)
						   | [] -> _
						   in setTab lexp 0
						end

		
		| TplGet(lexp, id) ->
		
		(*| Fun(str, e) ->
		| App(e1, e2) ->
		| If(cdn, th, ls) ->
		| LetIn(str, e1, e2) ->
		| LetRec(str, e1, e2) -> *)


(* let translate_seq seq =	
	match seq with
	|  *)

*)

let translate_program prog =
	let clj = Fun2clj.translate_program prog in
	let pimp = Clj2imp.translate_program clj in
	pimp
