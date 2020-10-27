module VSet = Set.Make(String)

let translate_program e =
  let fdefs = ref [] in
  let new_fname =
    let cpt = ref (-1) in
    fun () -> incr cpt; Printf.sprintf "fun_%i" !cpt
  in
  
  let rec tr_expr (e: Fun.expression) (bvars: VSet.t):
      Clj.expression * (string * int) list =
    let cvars = ref [] in
    let new_cvar =
      let cpt = ref 0 in (* commencera à 1 *)
      fun x -> incr cpt; cvars := (x, !cpt) :: !cvars; !cpt
    in
    
    let rec convert_var x bvars =
      Clj.(if VSet.mem x bvars
        then Name(x)
        else if List.mem_assoc x !cvars
        then CVar(List.assoc x !cvars)
        else CVar(new_cvar x))
        
    and crawl e bvars = match e with
      | Fun.Cst(n) ->
        Clj.Cst(n)

      | Fun.Bool(b) ->
        Clj.Bool(b)
          
      | Fun.Var(x) ->
        Clj.Var(convert_var x bvars)
          
      | Fun.Binop(op, e1, e2) ->
        Clj.Binop(op, crawl e1 bvars, crawl e2 bvars)

      | Fun.LetIn(x, e1, e2) ->
        Clj.LetIn(x, crawl e1 bvars, crawl e2 (VSet.add x bvars))

      | Fun.Tpl(lexp) -> 
        let rec crawl_list lin lout =
          match lin with
          | [] -> Clj.Tpl(lout)
          | h::t -> crawl_list t (lout @ [(crawl h bvars)])
        in crawl_list lexp []


      | Fun.TplGet(exp, idx) ->
        Clj.TplGet(crawl exp bvars, idx)

      | Fun.If(cdn, th, ls) -> 
        Clj.If(crawl cdn bvars, crawl th bvars, crawl ls bvars)

      | Fun.Fun(str, exp) ->
        let def = Clj.({name=str; 
          code=(crawl exp bvars); 
          param=
          List.nth 
          (VSet.elements bvars) 0}) 
      in fdefs := def :: !fdefs; 
      Clj.FunRef(str)


    in
    let te = crawl e bvars in
    te, !cvars

  in
  let code, _ = tr_expr e VSet.empty in
  Clj.({
    functions = !fdefs;
    code = code;
  })
