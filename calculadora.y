/* area de definicoes */
%{
	#include <stdio.h>
	#include <stdlib.h>

  #include "calculadora.h"
%}

%union {
    struct ast * a;
    double d;             // valor numérico do lexema
    struct symbol * s;    // qual símbolo
    struct symlist * sl;
    int fn;               // qual função pre-definida
}

/* definindo os tokens 
   NUM numeros inteiros e/ou reais 
   ADD adicao
   SUB subtracao
   MUL multiplicacao
   DIV divisao
   EOL final de linha
   OP  abertura de parentesis
   CP  fechamento de parentesis
   INV operador de inversao ( ~ )
*/
%token <d> NUM      // constantes numericas 
%token <s> NAME     // variaveis
%token <fn> FUNC    // funções pré-definidas
%token EOL          // fim de linha (enter)

%token IF THEN ELSE // comandos de desvio condicional
%token WHILE DO     // comando de repeticao
%token LET          // declaração de funcoes definidas pelo usuario
%token UMINUS       // '-'
%token <fn> CMP     // comparações ( ==, >, >=, <, <=, ...)

// %token OP CP     // '(' ')'
%token FIM       // sair da calculadora

/* associatividade de operadores */
%nonassoc CMP
%right '='
%left '+' '-' 
%left '*' '/' 
%nonassoc '|' UMINUS 

%type <a> expr stmt list explist
%type <sl> symlist

%start inputLine

%%

/* area regras gramaticais */

inputLine : /* regra vazia */
     | inputLine stmt EOL   { 
                              if ( debug ) dumpast( $2, 0);
                              printf("= %4.4g\n> ", eval( $2 ) );
                              treefree( $2 );
                            }
     | inputLine LET NAME '(' symlist ')' '=' list EOL {
                              dodef($3, $5, $8);
                              printf("Defined %s\n> ", $3->name);
                            }
     | inputLine error EOL  { yyerrok; printf("> "); }
     | inputLine EOL        { printf("> "); }
     | inputLine FIM EOL    { return 0; }
     // | inputLine SYMTAB EOL { printf("Print symbol table....\n"); 
     //                          printf("> ");
     //                        }
     ;

/* definição de um statement */
stmt : IF expr THEN list           { $$ = newflow('I', $2, $4, NULL); }
     | IF expr THEN list ELSE list { $$ = newflow('I', $2, $4, $6);   }
     | WHILE expr DO list          { $$ = newflow('W', $2, $4, NULL); }
     | expr                        
     ;

list : /* nothing */ { $$ = NULL; }
     | stmt ';' list { if ( $3 == NULL ) 
                          $$ = $1;
                       else 
                          $$ = newast('L', $1, $3);
                     }
     ;

expr : expr CMP expr         { $$ = newcmp(  $2, $1, $3 ); }
     | expr '+' expr         { $$ = newast( '+', $1, $3 ); }
     | expr '-' expr         { $$ = newast( '-', $1, $3 ); }
     | expr '*' expr         { $$ = newast( '*', $1, $3 ); }
     | expr '/' expr         { $$ = newast( '/', $1, $3 ); }
     | '|' expr              { $$ = newast( '|', $2, NULL ); }
     | '(' expr ')'          { $$ = $2; }
     | '-' expr %prec UMINUS { $$ = newast( 'M', $2, NULL ); }
     | NUM                   { $$ = newnum( $1 ); }
     | NAME                  { $$ = newref( $1 ); }
     | NAME '=' expr         { $$ = newasgn( $1, $3 ); } // assign (atribuicao)
     | NAME '(' explist ')'  { $$ = newcall( $1, $3 ); } // call : chamada (de funcao do usuario)
     | FUNC '(' explist ')'  { $$ = newfunc( $1, $3 ); } // func : funcao pre-definida
     ;  

explist : expr
     | expr ',' explist { $$ = newast('L', $1, $3); }
     ;

symlist : NAME          { $$ = newsymlist( $1, NULL ); }
     | NAME ',' symlist { $$ = newsymlist( $1, $3); }
     ;

%%

/* area de funcoes auxiliares */

int main() {
  printf("> ");
  int r = yyparse();
  printf("Calculadora finalizada com sucesso!\n");
	return r;
}


