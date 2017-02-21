
%{
  open Abstract_syntax_tree
%}

/*******************\
|*      tokens     *|
\*******************/
%token TOK_NODE
%token TOK_RETURN
%token TOK_LET
%token TOK_TEL
%token TOK_WHEN
%token TOK_MERGE

%token TOK_LPAREN
%token TOK_RPAREN
%token TOK_EQUAL
%token TOK_COMMA
%token TOK_TWO_COLON
%token TOK_COLON
%token TOK_SEMICOLON
%token TOK_PIPE
%token TOK_ARROW

%token TOK_AND
%token TOK_OR
%token TOK_XOR
%token TOK_NOT

%token <string> TOK_id
%token <string> TOK_constr  (* ident with an uppercase 1st letter *)
%token <int> TOK_int

%token <Abstract_syntax_tree.typ> TOK_type

%token TOK_EOF

%nonassoc TOK_MERGE
%nonassoc TOK_PIPE
%nonassoc TOK_WHEN

/*******************\
|*   entry point   *|
\*******************/
%start<Abstract_syntax_tree.prog> prog


%%

prog:
  | d=defs TOK_EOF { d }

op:
  | TOK_AND { And }
  | TOK_OR  { Or  }
  | TOK_XOR { Xor }
  | TOK_NOT { Not }

exp:
   | TOK_LPAREN; e=exp; TOK_RPAREN { e }
   | x=TOK_int { Const x }
   | id=TOK_id  { Var(id) }
   | TOK_LPAREN; t=tuple; TOK_RPAREN  { Tuple t }
   | o=op; TOK_LPAREN; args=explist; TOK_RPAREN { Op(o, args) }
   | f=TOK_id; TOK_LPAREN; args=explist; TOK_RPAREN { Fun(f, args) }
   | e=exp; TOK_WHEN; cstr=TOK_constr; TOK_LPAREN; x=TOK_id; TOK_RPAREN { Mux(e,cstr,x) }
   | TOK_MERGE; ck=TOK_id; c=caselist %prec TOK_MERGE { Demux(ck,c) }

caselist:
   | { [] }                                  
   | front=caselist TOK_PIPE; c=TOK_constr; TOK_ARROW; e=exp %prec TOK_PIPE { (c,e)::front }

tuple:
  | x=exp; TOK_COMMA; tail=explist    { x::(List.rev tail) }
                                     
explist:
  | x=exp                             { [ x ]     }
  | tail=explist; TOK_COMMA; x=exp    { x :: tail }

pat:
  | i=TOK_id                          { [ i ] }
  | TOK_LPAREN; l=patlist; TOK_RPAREN { l   }

patlist:
  | i=TOK_id                            { [ i ]     }
  | tail=patlist; TOK_COMMA; i=TOK_id   { i :: tail }

deq: (* returns a tuple list, is converted to AST by def *)
  | p=pat; TOK_EQUAL; e=exp                           { [ ( p, e ) ]  }
  | tail=deq; TOK_SEMICOLON; p=pat; TOK_EQUAL; e=exp  { (p,e) :: tail }

p:
  | l=plist         { l }

psingle:
  | x=TOK_id TOK_COLON t=TOK_type TOK_TWO_COLON ck=TOK_id
    { (x, t, ck) }

plist:
  | e=psingle                        { [ e ] }
  | tail=plist; TOK_COMMA; e=psingle { e :: tail }

def:
  | TOK_NODE f=TOK_id TOK_LPAREN p_in=p TOK_RPAREN TOK_RETURN p_out=p TOK_LET body=deq TOK_TEL
  { (f,p_in,p_out,body) }
  
defs:
  | d=def                { [ d ] }
  | dl=defs; d=def       { d::dl }

%%
