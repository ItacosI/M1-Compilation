type unop = Minus | Not
type binop =
  | Add | Sub | Mul | Div | Rem | Lsl | Lsr
  | Eq  | Neq | Lt  | Le  | Gt  | Ge
  | And | Or
      
type expression =
  | Cst   of int
  | Bool  of bool
  | Var   of string
  | Unop  of unop * expression
  | Binop of binop * expression * expression
  | Call  of string * expression list
  (* Pointeurs *)
  | Deref of expression
  | Addr  of string
  | PCall of expression * expression list
  | Sbrk  of expression
      
type instruction =
  | Putchar of expression
  | Set     of string * expression
  | If      of expression * sequence * sequence
  | While   of expression * sequence
  | Return  of expression
  (* Pointeurs *)
  | Write   of expression * expression
  | Expr    of expression
      
and sequence = instruction list

let array_access (t: expression) (i: expression): expression =
  failwith "array access not implemented (imp.ml)"

type function_def = {
  name: string;
  code: sequence;
  params: string list;
  locals: string list;
}
    
type program = {
  main: sequence;
  functions: function_def list;
  globals: string list;
}
