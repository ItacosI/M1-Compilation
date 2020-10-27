open Imp
open Mips

let push reg = sw reg 0 sp  @@ subi sp sp 4
let pop  reg = addi sp sp 4 @@ lw reg 0 sp

let new_label =
  let cpt = ref (-1) in
  fun () -> incr cpt; Printf.sprintf "__label_%i" !cpt
        
let rec tr_expr e =
	match e with
	| Cst(n) -> li t0 n @@ push t0
	| Var(x) -> la t0 x @@ lw t0 0 t0 @@ push t0
	| Binop(op, a, b) -> begin match op with
		| Add -> match a with
					| _ of Int -> begin   (* Addi Cst * expression *)
								  tr_expr b
							   @@ pop t0
							   @@ addi t0 t0 a
							   @@ push t0  
								  end
					| _ -> match b with
							| _ of Int -> begin   (* Addi expression * Cst *)
										  tr_expr a
									   @@ pop t0
									   @@ addi t0 t0 b
									   @@ push t0 
									      end
							| _  ->  begin       (* Add expression * expression *)
									 tr_expr a
								  @@ tr_expr b
								  @@ pop t0
								  @@ pop t1
								  @@ add t0 t1 t0
								  @@ push t0
								     end




		| Mul -> tr_expr a
			  @@ tr_expr b
		      @@ pop t0
			  @@ pop t1
			  @@ mul t0 t1 t0
			  @@ push t0

		| Sub -> tr_expr b
			  @@ tr_expr a
			  @@ pop t0
			  @@ pop t1
			  @@ sub t0 t0 t1
			  @@ push t0

		| Div -> tr_expr b
			  @@ tr_expr a
			  @@ pop t0
			  @@ pop t1
			  @@ div t0 t0 t1
			  @@ push t0			  

		| Rem -> tr_expr b
			  @@ tr_expr a
			  @@ pop t0
			  @@ pop t1
			  @@ rem t0 t0 t1
			  @@ push t0

		| Lt -> tr_expr b
			 @@ tr_expr a
			 @@ pop t0
			 @@ pop t1
			 @@ slt t0 t0 t1
			 @@ push t0

		| Gt -> tr_expr b
			 @@ tr_expr a
			 @@ pop t0
			 @@ pop t1
			 @@ sgt t0 t0 t1
			 @@ push t0

		| Le -> tr_expr b
			 @@ tr_expr a
			 @@ pop t0
			 @@ pop t1
			 @@ sle t0 t0 t1
			 @@ push t0

		| Ge -> tr_expr b
			 @@ tr_expr a
			 @@ pop t0
			 @@ pop t1
			 @@ sge t0 t0 t1
			 @@ push t0
		
		| Lsl -> tr_expr b
			  @@ tr_expr a
			  @@ pop t0
			  @@ pop t1
			  @@ sll t0 t0 t1
			  @@ push t0

		| Lsr -> tr_expr b
			  @@ tr_expr a
			  @@ pop t0
			  @@ pop t1
			  @@ srl t0 t0 t1
			  @@ push t0
		
		| Eq -> tr_expr a
			 @@ tr_expr b
			 @@ pop t0
			 @@ pop t1
			 @@ seq t0 t0 t1 
			 @@ push t0

		| Neq -> tr_expr a
			  @@ tr_expr b
			  @@ pop t0
			  @@ pop t1
			  @@ sne t0 t0 t1 
			  @@ push t0

		| And -> let lb_exit = new_label () in (* analyse paresseuse *)
				 tr_expr a
			  @@ pop t0
			  @@ beqz t0 lb_exit (* Branche si a est faux *)
			  @@ tr_expr b
			  @@ pop t1
			  @@ and_ t0 t0 t1 
			  @@ label lb_exit
			  @@ push t0

		| Or  -> let lb_exit = new_label () in (* analyse paresseuse *)
			     tr_expr a
			  @@ pop t0
			  @@ bnez t0 lb_exit(* Branche si a est vrai *)
			  @@ tr_expr b
			  @@ pop t1
			  @@ or_ t0 t0 t1 
			  @@ label lb_exit
			  @@ push t0
	end

	| Unop(op, a) -> begin match op with
		| Minus -> tr_expr a
				@@ pop t0
				@@ neg t0 t0
				@@ push t0
		| Not   -> tr_expr a
				@@ pop t0
				@@ not_ t0 t0
				@@ push t0
	end


	| Bool(b) -> begin match b with
		| true  -> li t0 (-1)
				@@ push t0 
		| false -> li t0 0
				@@ push t0
	end

	| Call(str, exp) -> pushlist exp
						@@ jal str
						@@ pop v0
						@@ desalloc (List.length exp)
						@@ push v0
						and pushlist liste =
							match liste with
								| h :: t -> pushlist t @@ tr_expr h
								| _ -> nop
						and desalloc nb = 
							match nb with
								| 0 -> nop
								| _ -> pop t1 @@ desalloc (nb-1)

	| Deref(exp) -> tr_expr exp
				 @@ pop t0
				 @@ lw t1 t0
				 @@ push t1

	| Addr(p) -> la t0 p
			  @@ push t0

	| PCall(p, exp) -> pushlist exp
					@@ tr_expr p
					@@ pop t0
					@@ jalr t0
					@@ pop v0
					@@ desalloc (List.length exp)
					@@ push v0
					and pushlist liste =
						match liste with
							| h :: t -> pushlist t @@ tr_expr h
							| _ -> nop
					and desalloc nb = 
						match nb with
							| 0 -> nop
							| _ -> pop t1 @@ desalloc (nb-1)

	| Sbrk(exp) -> tr_expr exp
				@@ li v0 9
				@@ pop a0
				@@ syscall
				@@ push v0

	



let rec tr_instr i =
	match i with
	| Putchar(c) -> tr_expr c 
				 @@ li v0 11
				 @@ pop a0
				 @@ syscall

	| Set(x, e) -> tr_expr e 
				@@ la t0 x
				@@ pop t1
				@@ sw t1 0 t0

	| If(e, sq1, sq2) -> let nl1 = new_label () in
						 let nl2 = new_label () in 
						 tr_expr e
					  @@ pop t0
					  @@ beqz t0 nl1
					  @@ tr_seq sq1
					  @@ b nl2
					  @@ label nl1
					  @@ tr_seq sq2
					  @@ label nl2

	| While(e, sq) -> let nl1 = new_label () in
					  let nl2 = new_label () in 
					  label nl2
				   @@ tr_expr e
				   @@ pop t0
				   @@ beqz t0 nl1
				   @@ tr_seq sq
				   @@ b nl2
				   @@ label nl1

	| Return(exp) -> tr_expr exp
				  @@ jr ra

	| Write(p, x) -> tr_expr x
				  @@ tr_expr p
				  @@ pop a0
				  @@ pop t0
				  @@ sw a0 t0

	| Expr(exp) -> tr_expr exp



      
and tr_seq = function
  | []   -> nop
  | [i]  -> tr_instr i
  | i::s -> tr_instr i @@ tr_seq s


exception ParameterNotFound

let rec find_id liste element acc =
	match liste with
	| [] -> raise ParameterNotFound
	| h::t when (h == element) -> acc
	| h::t -> find_id t element (acc+1)


let tr_fun f =
	let loop = new_label () in
	let exit = new_label () in 
	comment f.name
 @@ label f.name
 @@ move fp sp (* etape 1 *)
 @@ tr_seq f.code (* déroulé du code *)
 @@ pop v0	(* récupération res *)
 @@ beq fp sp exit (* check si pile vide apres fp *)
 @@ label loop (* boucle de vidage *)
 @@ pop t0 
 @@ bne fp sp loop
 @@ label exit 
 @@ push v0	(* remise res sur pile *)


    
let translate_program prog =
  let init =
    beqz a0 "init_end"
    @@ lw a0 0 a1
    @@ jal "atoi"
    @@ la t0 "arg"
    @@ sw v0 0 t0
    @@ label "init_end"
  and close =
    li v0 10
    @@ syscall
  and built_ins =
    label "atoi"
    @@ move t0 a0
    @@ li   t1 0
    @@ li   t2 10
    @@ label "atoi_loop"
    @@ lbu  t3 0 t0
    @@ beq  t3 zero "atoi_end"
    @@ li   t4 48
    @@ blt  t3 t4 "atoi_error"
    @@ li   t4 57
    @@ bgt  t3 t4 "atoi_error"
    @@ addi t3 t3 (-48)
    @@ mul  t1 t1 t2
    @@ add  t1 t1 t3
    @@ addi t0 t0 1
    @@ b "atoi_loop"
    @@ label "atoi_error"
    @@ li   v0 10
    @@ syscall
    @@ label "atoi_end"
    @@ move v0 t1
    @@ jr   ra

    @@ comment "print_int"
	@@ label "print_int"
	@@ lw a0 4 sp
	@@ li v0 1
	@@ syscall
	@@ sw a0 0 sp
	@@ subi sp sp 4
	@@ jr ra
	 
	@@ comment "power"
	@@ label "power"
	@@ lw s0 8 sp
	@@ lw s1 4 sp
	@@ li t0 1
	@@ b "power_loop_guard"
	@@ label "power_loop_code"
	@@ mul t0 t0 s1
	@@ subi s0 s0 1
	@@ label "power_loop_guard"
	@@ bgtz s0 "power_loop_code"
	@@ sw t0 0 sp
	@@ subi sp sp 4
	@@ jr ra

  in

  let main_code = tr_seq prog.main in
  let functions_code = List.fold_right (fun fct acc -> tr_fun fct @@ acc) prog.functions nop in
  let text = init @@ main_code @@ close @@ built_ins @@ functions_code
  and data = List.fold_right
    (fun id code -> label id @@ dword [0] @@ code)
    prog.globals (label "arg" @@ dword [0])
  in
  
  { text; data }
