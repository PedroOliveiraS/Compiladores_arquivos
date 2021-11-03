
enum bifs {          /* funções pré-definidas */
	B_sqrt = 1,      // raíz quadrada: sqrt(x)
	B_exp,           // exponenciação: exp(x)
	B_log,           // logaritmo:     log(x)
	B_print,         // print:         print(x)
};

/* Identificadores para os tipos de nó da AST
	'+' 
	'-' 
	'*' 
	'/' 
	'|'
	'0'-'7' operadores de comparação (bit coded 04 equal, 02 less, 01 greater, ... )
	'M' unary minus (inversão)
	'L' expression or statement list
	'I' IF statement
	'W' WHILE statement
	'N' symbol ref
	'=' assignment
	'S' list of symbols
	'F' built in function call
	'C' user function call
 */

/* Definição da Arvore Sintática Abstrata */

/* definicao para nó da árvore sintática */
struct ast {
	int nodetype;            // tipo do nó da AST
	struct ast * left;       // sub-árvore esquerda
	struct ast * right;		 // sub-árvore direita
};

/* tabela de simbolos */
struct symbol {
	char * name;                  /* a variable name */
	double value;                 /* a variable value */
	
	struct ast * func;            /* stmt for the function */
	struct symlist * syms;        /* list of dummy args */
};

/* list of symbols, for an argument list */
struct symlist {
	struct symbol * sym;
	struct symlist * next;
};

/* simple symtab of fixed size */
#define NHASH 9997
struct symbol symtab[NHASH];


struct fncall {              // built-in function
	int nodetype;            // type 'F'
	struct ast * l;			 // lista de argumentos da função
	enum bifs functype;		 // qual função pré-definida
};

struct ufncall {             // user function
	int nodetype;            // type 'C'
	struct ast * l;			 // lista de argumentos da função
	struct symbol * s;       // entrada na tabela de símbolos para a função
};

struct flow {                // flow control (if-then-else, while-do)
	int nodetype;			 // type 'I' or 'W'
	struct ast * cond;       // condição
	struct ast * tl;         // "then" branch or "do" list
	struct ast * el;         // optional "else" branch
};

/* definicao para nó contendo valor numérico */
struct numval {             // constantes
	int nodetype;    		// tipo: 'K'
	double number;			// valor da constante
};

struct symref {				// referências para símbolos
	int nodetype;			// type 'N'
	struct symbol * s;		// entrada na tabela de símbolos para a referência
};

struct symasgn {			// atribuições
	int nodetype;			// type '='
	struct symbol * s;		// entrada na tabela de símbolos para a variável atribuída (LHS)
	struct ast * v;			// expressão da atribuição (RHS)
};

/* busca uma entrada na tabela de símbolos */
struct symbol * lookup(char *);

/* define a function */
void dodef(struct symbol *name, struct symlist *syms, struct ast *stmts);

/* evaluate an AST */
double eval( struct ast * );

/* destrói a AST */
void treefree( struct ast * );

/* insere um novo nó, não terminal, na AST */
struct ast * newast( int nodetype, struct ast * left, struct ast * right );
struct ast * newcmp(int cmptype, struct ast *l, struct ast *r);
struct ast * newfunc(int functype, struct ast *l);
struct ast * newcall(struct symbol *s, struct ast *l);
struct ast * newref(struct symbol *s);
struct ast * newasgn(struct symbol *s, struct ast *v);
struct ast * newnum(double d);
struct ast * newflow(int nodetype, struct ast *cond, struct ast *tl, struct ast *tr);

/* insere um novo nó, terminal, na AST */
struct ast * newnum( double value );

struct symlist * newsymlist(struct symbol * sym, struct symlist * next);

void symlistfree(struct symlist * sl);

char * getsymbols(struct symlist * lst );

/* interface to the lexer */
extern int yylineno;     /* variável global do lexer (scanner) */
void yyerror(char * s, ...);

extern int debug;
void dumpast(struct ast *a, int level);

static double callbuiltin(struct fncall *);
static double calluser(struct ufncall *);

static char * concatenar(const char * s1, const char * s2);
