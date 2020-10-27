module STbl = Map.Make(String)

let tr_var v env = match v with
  | Clj.Name(x) ->
    Imp.(if STbl.mem x env then Var(STbl.find x env) else Var x)
      
  | Clj.CVar(n) ->
    Imp.(array_get (Var "closure") (Cst n))
      
let tr_expr e env =
  let cpt = ref (-1) in
  let vars = ref [] in
  let new_var id =
    incr cpt;
    let v = Printf.sprintf "%s_%i" id !cpt in
    vars := v :: !vars;
    v
  in
  
  let rec tr_expr (e: Clj.expression) (env: string STbl.t):
      Imp.sequence * Imp.expression =
    match e with
      | Clj.Cst(n) ->
        [], Imp.Cst(n)

      | Clj.Bool(b) ->
        [], Imp.Bool(b)

      | Clj.Var(v) ->
        [], tr_var v env
          
      | Clj.Binop(op, e1, e2) ->
        let is1, te1 = tr_expr e1 env in
        let is2, te2 = tr_expr e2 env in
        is1 @ is2, Imp.Binop(op, te1, te2)
          
      | Clj.LetIn(x, e1, e2) ->
        let lv = new_var x in
        let is1, t1 = tr_expr e1 env in
        let is2, t2 = tr_expr e2 (STbl.add x lv env) in
        Imp.(is1 @ [Set(lv, t1)] @ is2, t2)

      | Clj.Tpl(lexp) -> 
        let tab = new_var "" in
        let rec setTab l acc ins =
          match l with
          | [] -> ins, (Imp.Var(tab))
          | h::t -> 
            let ins1, exp1 = tr_expr h env in setTab t (acc+1) (ins @ ins1 @ [Imp.array_set (Imp.Var(tab)) (Imp.Cst(acc)) exp1])
        in setTab lexp 0 [(Imp.Set(tab, (Imp.array_create (Imp.Cst(List.length lexp)))))]

      | Clj.TplGet(exp, idx) ->
        let ins1, exp1 = tr_expr exp env in
        ins1, (Imp.array_get (exp1) (Imp.Cst(idx)))

      | Clj.If(cdn, th, ls) -> 
        let ins1, exp1 = tr_expr cdn env in
        let ins2, exp2 = tr_expr th env in
        let ins3, exp3 = tr_expr ls env in
        begin
        match exp1 with
         | Imp.Bool(true) -> [Imp.If(exp1, ins2 @ [Imp.Expr(exp2)], ins3 @ [Imp.Expr(exp3)])], exp2
         | Imp.Bool(false) -> [Imp.If(exp1, ins2 @ [Imp.Expr(exp2)], ins3 @ [Imp.Expr(exp3)])], exp3
       end

      (* | Clj.FunRef(str) ->

       [], Imp.Call(str, env) *)

      


  in
    
  let is, te = tr_expr e env in
  is, te, !vars

    
let tr_fdef fdef =
  let env =
    let x = Clj.(fdef.param) in
    STbl.add x ("param_" ^ x) STbl.empty
  in
  let is, te, locals = tr_expr Clj.(fdef.code) env in
  Imp.({
    name = Clj.(fdef.name);
    code = is @ [Return te];
    params = ["param_" ^ Clj.(fdef.param); "closure"];
    locals = locals;
  })


let translate_program prog =
  let functions = List.map tr_fdef Clj.(prog.functions) in
  let is, te, globals = tr_expr Clj.(prog.code) STbl.empty in
  let main = Imp.(is @ [Expr(Call("print_int", [te]))]) in
  Imp.({main; functions; globals})
    
