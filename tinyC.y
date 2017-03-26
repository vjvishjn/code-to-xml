%{

#include <string.h>
#include <iostream>
#include "parser.h"
#include <stdio.h>
#include <vector>
using namespace std;

extern "C" FILE *yyin;
extern int line_num;
extern int col_num;
extern int start_line;
extern int start_col;
extern int prev_col;
extern int prev_line;
extern int prev_tok_line;
int start_expr_statement_line = -1;
int start_expr_statement_col = -1;
int func_start_line = -1;
int func_start_col = -1;
int preProc_start_line;
int preProc_start_col;
vector<int> compoundStatementsStack;


extern int yylex();
void yyerror(const char *s);
#define NSYMS 20	/* maximum number of symbols */
symboltable symtab[NSYMS];

%}

%union {
	int intval;
	double dval;
	char *sval;
	struct symtab *symp;
}

%token <symp> ID
%token <intval> INT_CONST
%token <dval> FLOAT_CONST
%token <sval> STRING_CONST
%token ENUM_CONST


%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO
%token DOUBLE ELSE ENUM EXTERN FLOAT FOR GOTO IF INLINE
%token INT LONG REGISTER RESTRICT RETURN SHORT SIGNED
%token SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED USING NAMESPACE STD
%token VOID VOLATILE WHILE _BOOL _COMPLEX _IMAGINARY PREPROCESSORDIRECTIVE

%token LPARAN RPARAN LBRACKET RBRACKET LBRACE RBRACE
%token ADD_OP SUB_OP MULT_OP DIV_OP MODULO_OP
%token LSHIFT_OP RSHIFT_OP
%token LESS_OP GREATER_OP LEQ_OP GEQ_OP EQ_OP NEQ_OP
%token INC_OP DEC_OP
%token ASSIGN_OP ADD_ASSIGN_OP SUB_ASSIGN_OP MULT_ASSIGN_OP DIV_ASSIGN_OP MODULO_ASSIGN_OP
%token QUESTIONMARK_OP COLON COMMA
%token LOGICAL_NEG_OP LOGICAL_AND_OP LOGICAL_OR_OP
%token BIT_NOT_OP BIT_AND_OP BIT_OR_OP BIT_XOR_OP
%token BIT_AND_ASSIGN_OP BIT_OR_ASSIGN_OP BIT_XOR_ASSIGN_OP BIT_LSHIFT_ASSIGN_OP BIT_RSHIFT_ASSIGN_OP
%token SEMICOLON ELLIPSES HASH DOT_OP STRUCT_REFERENCE INCLUDE


%nonassoc UMINUS_OP UPLUS_OP ADDRESS_OF_OP CONTENT_OF_OP
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%start start
%%




primary_expression:
		  ID {
		  		if(start_expr_statement_col == -1){
		  			start_expr_statement_col = start_col;
		  		}
					if(start_expr_statement_line == -1){
						start_expr_statement_line = start_line;
					}
		  	}
		| INT_CONST
		| FLOAT_CONST
		| STRING_CONST
		| LPARAN expression RPARAN
		;

identifieropt:
		  ID {
			if(start_expr_statement_col == -1){
				start_expr_statement_col = start_col;
			}
			if(start_expr_statement_line == -1){
				start_expr_statement_line = start_line;
			}
		  	}
		|
		;


postfix_expression:
		  primary_expression
		| postfix_expression LBRACKET expression RBRACKET
		| postfix_expression LPARAN argument_expression_listopt RPARAN
		| postfix_expression DOT_OP ID
		| postfix_expression STRUCT_REFERENCE ID
		| postfix_expression INC_OP
		| postfix_expression DEC_OP
		| LPARAN type_name RPARAN left_bracket initializer_list RBRACE { compoundStatementsStack.pop_back(); }
		| LPARAN type_name RPARAN left_bracket initializer_list COMMA RBRACE {compoundStatementsStack.pop_back();}
		;

argument_expression_listopt:
		  argument_expression_list
		|
		;

argument_expression_list:
		  assignment_expression
		| argument_expression_list COMMA assignment_expression
		;

unary_expression:
		  postfix_expression
		| INC_OP unary_expression
		| DEC_OP unary_expression
		| unary_operator cast_expression
		| SIZEOF unary_expression
		| SIZEOF LPARAN type_name RPARAN
		;

unary_operator:
		  BIT_AND_OP %prec ADDRESS_OF_OP
		| MULT_OP %prec CONTENT_OF_OP
		| ADD_OP %prec UPLUS_OP
		| SUB_OP %prec UMINUS_OP
		| BIT_NOT_OP
		| LOGICAL_NEG_OP
		;

cast_expression:
		  unary_expression
		| LPARAN type_name RPARAN cast_expression
		;

multiplicative_expression:
		  cast_expression
		| multiplicative_expression MULT_OP cast_expression
		| multiplicative_expression DIV_OP cast_expression
		| multiplicative_expression MODULO_OP cast_expression
		;

additive_expression:
		  multiplicative_expression
		| additive_expression ADD_OP multiplicative_expression
		| additive_expression SUB_OP multiplicative_expression
		;

shift_expression:
		  additive_expression
		| shift_expression LSHIFT_OP additive_expression
		| shift_expression RSHIFT_OP additive_expression
		;

relational_expression:
		  shift_expression
		| relational_expression LESS_OP shift_expression
		| relational_expression GREATER_OP shift_expression
		| relational_expression LEQ_OP shift_expression
		| relational_expression GEQ_OP shift_expression
		;

equality_expression:
		  relational_expression
		| equality_expression EQ_OP relational_expression
		| equality_expression NEQ_OP relational_expression
		;

AND_expression:
		  equality_expression
		| AND_expression BIT_AND_OP equality_expression
		;

exclusive_OR_expression:
		  AND_expression
		| exclusive_OR_expression BIT_XOR_OP AND_expression
		;

inclusive_OR_expression:
		  exclusive_OR_expression
		| inclusive_OR_expression BIT_OR_OP exclusive_OR_expression
		;

logical_AND_expression:
		  inclusive_OR_expression
		| logical_AND_expression LOGICAL_AND_OP inclusive_OR_expression
		;

logical_OR_expression:
		  logical_AND_expression
		| logical_OR_expression LOGICAL_OR_OP logical_AND_expression
		;

conditional_expression:
		  logical_OR_expression
		| logical_OR_expression QUESTIONMARK_OP expression COLON conditional_expression
		;

assignment_expressionopt:
		  assignment_expression
		|
		;

assignment_expression:
		  conditional_expression
		| unary_expression assignment_operator assignment_expression
		;


assignment_operator:
		  ASSIGN_OP
		| MULT_ASSIGN_OP
		| DIV_ASSIGN_OP
		| MODULO_ASSIGN_OP
		| ADD_ASSIGN_OP
		| SUB_ASSIGN_OP
		| BIT_LSHIFT_ASSIGN_OP
		| BIT_RSHIFT_ASSIGN_OP
		| BIT_AND_ASSIGN_OP
		| BIT_XOR_ASSIGN_OP
		| BIT_OR_ASSIGN_OP
		;


expressionopt:
		  expression
		|
		;

expression:
		  assignment_expression
		| expression COMMA assignment_expression
		;

constant_expression:
		  conditional_expression
		;

declaration:
		  declaration_specifiers init_declarator_listopt SEMICOLON
		  {
		  	func_start_line = -1;
		  	func_start_col = -1;
		  }
		;

declaration_specifiersopt:
		  declaration_specifiers
		|
		;

declaration_specifiers:
		  storage_class_specifier declaration_specifiersopt
		| type_specifier declaration_specifiersopt
		| type_qualifier declaration_specifiersopt
		| function_specifier declaration_specifiersopt
		;

init_declarator_listopt:
		  init_declarator_list
		|
		;

init_declarator_list:
		  init_declarator
		| init_declarator_list COMMA init_declarator
		;

init_declarator:
		  declarator
		| declarator ASSIGN_OP initializer
		;

storage_class_specifier:
		  EXTERN
		| STATIC
		| AUTO
		| REGISTER
		// |TYPEDEF
		;

type_specifier:
		  VOID {
		  			if(func_start_line == -1)
		  				func_start_line = line_num;
		  			if(func_start_col == -1)
		  				func_start_col = col_num - 4;
		  	  	}
		| CHAR  {
		  			if(func_start_line == -1)
		  				func_start_line = line_num;
		  			if(func_start_col == -1)
		  				func_start_col = col_num - 4;
		  	  	}
		| SHORT {
		  			if(func_start_line == -1)
		  				func_start_line = line_num;
		  			if(func_start_col == -1)
		  				func_start_col = col_num - 5;
		  	  	}
		| INT {
		  			if(func_start_line == -1)
		  				func_start_line = line_num;
		  			if(func_start_col == -1)
		  				func_start_col = col_num - 3;
		  	  	}
		| LONG {
		  			if(func_start_line == -1)
		  				func_start_line = line_num;
		  			if(func_start_col == -1)
		  				func_start_col = col_num - 4;
		  	  	}
		| FLOAT {
		  			if(func_start_line == -1)
		  				func_start_line = line_num;
		  			if(func_start_col == -1)
		  				func_start_col = col_num - 5;
		  	  	}
		| DOUBLE {
		  			if(func_start_line == -1)
		  				func_start_line = line_num;
		  			if(func_start_col == -1)
		  				func_start_col = col_num - 6;
		  	  	}
		| SIGNED  {
		  			if(func_start_line == -1)
		  				func_start_line = line_num;
		  			if(func_start_col == -1)
		  				func_start_col = col_num - 6;
		  	  	}
		| UNSIGNED  {
		  			if(func_start_line == -1)
		  				func_start_line = line_num;
		  			if(func_start_col == -1)
		  				func_start_col = col_num - 8;
		  	  		}
		| _BOOL {
		  			if(func_start_line == -1)
		  				func_start_line = line_num;
		  			if(func_start_col == -1)
		  				func_start_col = col_num - 4;
		  	  	}
		| _COMPLEX
		| _IMAGINARY
		| USING
		| NAMESPACE
        | STD
		| struct_or_union_specifier
		| enum_specifier
/*		| typedef_name */
		;


struct_or_union_specifier:
		  struct_or_union identifieropt left_bracket struct_declaration_list RBRACE {compoundStatementsStack.pop_back();}
		| struct_or_union ID pointeropt
		;

struct_or_union:
		  STRUCT
		| UNION
		;

struct_declaration_list:
		  struct_declaration
		| struct_declaration_list struct_declaration
		;

struct_declaration:
		  specifier_qualifier_list struct_declarator_list SEMICOLON
		;


specifier_qualifier_listopt:
		  specifier_qualifier_list
		|
		;

specifier_qualifier_list:
		  type_specifier specifier_qualifier_listopt
		| type_qualifier specifier_qualifier_listopt
		;

struct_declarator_list:
		  struct_declarator
		| struct_declarator_list COMMA struct_declarator
		;

struct_declarator:
		  declarator
		| declaratoropt COLON constant_expression
		;


enum_specifier:
		  ENUM identifieropt left_bracket enumerator_list RBRACE {compoundStatementsStack.pop_back();}
		| ENUM identifieropt left_bracket enumerator_list COMMA RBRACE {compoundStatementsStack.pop_back();}
		| ENUM ID
		;

enumerator_list:
		  enumerator
		| enumerator_list COMMA enumerator
		;

enumerator:
		  ENUM_CONST
		| ENUM_CONST ASSIGN_OP constant_expression
		;

type_qualifier:
		  CONST
		| RESTRICT
		| VOLATILE
		;

function_specifier:
		  INLINE
		;

declaratoropt:
		  declarator
		|
		;


declarator:
		  pointeropt direct_declarator
		;

direct_declarator:
		  ID
		| LPARAN declarator RPARAN
		| direct_declarator LBRACKET type_qualifier_listopt assignment_expressionopt RBRACKET
		| direct_declarator LBRACKET STATIC type_qualifier_listopt assignment_expression RBRACKET
		| direct_declarator LBRACKET type_qualifier_list STATIC assignment_expression RBRACKET
		| direct_declarator LBRACKET type_qualifier_listopt MULT_OP RBRACKET %prec CONTENT_OF_OP
		| direct_declarator LPARAN parameter_type_list RPARAN
		| direct_declarator LPARAN identifier_listopt RPARAN
		;

type_qualifier_listopt:
		  type_qualifier_list
		|
		;

pointeropt:
		  pointer
		|
		;

pointer:
		  MULT_OP type_qualifier_listopt %prec CONTENT_OF_OP
		| MULT_OP type_qualifier_listopt pointer %prec CONTENT_OF_OP
		;

type_qualifier_list:
		  type_qualifier
		| type_qualifier_list type_qualifier
		;
/*
parameter_type_listopt:
		  parameter_type_list
		|
		;
*/

parameter_type_list:
		  parameter_list
		| parameter_list COLON ELLIPSES
		;

parameter_list:
		  parameter_declaration
		| parameter_list COMMA parameter_declaration
		;

parameter_declaration:
		  declaration_specifiers declarator
		| declaration_specifiers // abstract_declaratoropt
		;

identifier_listopt:
		  identifier_list
		|
		;



identifier_list:
		  ID
		| identifier_list COMMA ID
		;

type_name:
		  specifier_qualifier_list /* abstract_declaratoropt */
		;
/*
abstract_declaratoropt:
		  abstract_declarator
		|
		;

abstract_declarator:
		  pointer
		| pointeropt direct_abstract_declarator
		;

direct_abstract_declaratoropt:
		  direct_abstract_declarator
		|
		;

direct_abstract_declarator:
		  LPARAN abstract_declarator RPARAN
		| direct_abstract_declaratoropt LBRACKET assignment_expressionopt RBRACKET
		| direct_abstract_declaratoropt LBRACKET MULT_OP RBRACKET %prec CONTENT_OF_OP
		| direct_abstract_declaratoropt LPARAN parameter_type_listopt RPARAN
		;
*/

/*
typedef_name:
		  ID
		;
*/

initializer:
		  assignment_expression
		| left_bracket initializer_list RBRACE {compoundStatementsStack.pop_back();}
		| left_bracket initializer_list COMMA RBRACE {compoundStatementsStack.pop_back();}
		;

initializer_list:
		  designationopt initializer
		| initializer_list COMMA designationopt initializer
		;

designationopt:
		  designation
		|
		;

designation:
		  designator_list ASSIGN_OP
		;

designator_list:
		  designator
		| designator_list designator
		;

designator:
		  LBRACKET constant_expression RBRACKET
		| DOT_OP ID
		;

/*
preprocessor_list:
		 HASH identifier_list LESS_OP identifier_list GREATER_OP
		| HASH identifier_list LESS_OP identifier_list GREATER_OP
		;

		*/
statement:
		  labeled_statement
		| compound_statement
		| expression_statement {
									printf("ExpressionStatement:\t=> StartLine: %d StartColumn: %d ", start_expr_statement_line, start_expr_statement_col);
									printf("EndLine: %d EndColumn: %d\n", line_num, prev_col);
									start_expr_statement_col = -1;
									start_expr_statement_line = -1;

								}
		| selection_statement
		| iteration_statement
		| jump_statement
		;

labeled_statement:
		  ID COLON statement
		| CASE constant_expression COLON statement
		| DEFAULT COLON statement
		;

compound_statement:
		  left_bracket block_item_listopt RBRACE
		  {
		  		printf("CompoundStatement:\t=> StartLine: %d EndLine: %d\n", compoundStatementsStack.back(), line_num);
		  		compoundStatementsStack.pop_back();
		  }
		;

left_bracket:
		   LBRACE
		    {
		    	compoundStatementsStack.push_back(line_num);
			}
		;
block_item_listopt:
		  block_item_list
		|
		;

block_item_list:
		  block_item
		| block_item_list block_item
		;

block_item:
		  declaration
		| statement
		;

expression_statement:
		  expressionopt SEMICOLON
		;

selection_statement:
		   if_only {printf("IfStatementEnd:\t=> EndLine: %d EndColumn: %d\n", line_num, col_num);} %prec LOWER_THAN_ELSE
		|  if_only ELSE statement {printf("If-ElseStatement:\t=> EndLine: %d EndColumn: %d\n", line_num, col_num);}
		|  switch_prologue statement {printf("SwitchStatement:\t=> EndLine: %d EndColumn: %d\n\n", line_num, col_num);}
		;

if_only:
		if_prologue statement {printf("IfPartOfStatement:\t=> EndLine: %d EndColumn: %d\n", line_num, col_num);}

iteration_statement:
		  while_prologue statement {printf("WhileStatementEnd:\t=> EndLine: %d EndColumn: %d\n", line_num, col_num);}
		| DO statement do_while_epilogue {printf("Do-WhileStatementEnd:\t=> EndLine: %d EndColumn: %d\n", line_num, col_num);}
		|  for_prologue statement {printf("ForEndStatement:\t=> EndLine: %d EndColumn: %d\n", line_num, col_num);}
		;

switch_prologue:
					SWITCH LPARAN expression RPARAN { start_expr_statement_col = -1; start_expr_statement_line = -1; printf("SwitchHeader:\t=> EndLine: %d EndColumn: %d\n", line_num, col_num);}
if_prologue:
			IF LPARAN expression RPARAN { start_expr_statement_col = -1; start_expr_statement_line = -1; printf("IfHeader:\t=> EndLine: %d EndColumn: %d\n", line_num, col_num);}
while_prologue:
			WHILE LPARAN expression RPARAN { start_expr_statement_col = -1; start_expr_statement_line = -1; printf("WhileHeader:\t=> EndLine: %d EndColumn: %d\n", line_num, col_num);}

do_while_epilogue:
			WHILE LPARAN expression RPARAN SEMICOLON { start_expr_statement_col = -1; start_expr_statement_line = -1; printf("Do-WhileFooter:\t=> EndLine: %d EndColumn: %d\n", line_num, col_num);}

for_prologue:
			FOR LPARAN expressionopt SEMICOLON expressionopt SEMICOLON expressionopt RPARAN
				{ start_expr_statement_col = -1; start_expr_statement_line = -1; printf("ForHeader:\t=> EndLine: %d EndColumn: %d\n", line_num, col_num);}
		|	FOR LPARAN declaration expressionopt SEMICOLON expressionopt RPARAN
			{ start_expr_statement_col = -1; start_expr_statement_line = -1; printf("ForHeader:\t=> EndLine: %d EndColumn: %d\n", line_num, col_num);}


jump_statement:
		  GOTO ID SEMICOLON
		| CONTINUE SEMICOLON
		| BREAK SEMICOLON
		| RETURN expressionopt SEMICOLON
		;

start: translation_unit
     	;

translation_unit:
		  external_declaration {start_expr_statement_col = -1; start_expr_statement_line = -1;}
		| translation_unit external_declaration
		;

external_declaration:
		  function_definition
		| declaration
		| preprocessor_directives
		;

preprocessor_directives:
		  hash directive
		  {		  }
		;

hash:
		  HASH
		  {
		  	preProc_start_line = line_num;
			preProc_start_col = col_num - 1;
		  }
		  ;

directive:
		  INCLUDE LESS_OP ID DOT_OP ID GREATER_OP
		| INCLUDE STRING_CONST
		;



function_definition:
		  function_prologue compound_statement
		  {
		  	printf("FunctionBody:\t=> StartLine: %d StartColumn: %d EndLine: %d EndColumn: %d\n",func_start_line, func_start_col, line_num, col_num);
		  	func_start_line = -1;
		  	func_start_col = -1;
		  }
		;

function_prologue:
		  declaration_specifiers declarator declaration_listopt
		  {
		  	printf("FunctionHeader:\t=> StartLine: %d StartColumn: %d EndLine: %d EndColumn: %d\n", func_start_line, func_start_col, prev_tok_line, prev_col);
		  	func_start_line = -1;
		  	func_start_col = -1;
		  }
		;

declaration_listopt:
		  declaration_list
		|
		;

declaration_list:
		  declaration
		| declaration_list declaration
		;

%%



struct symtab *symlook(char *s) {
	//char *p;
	struct symtab *sp;
	for(sp = symtab; sp < &symtab[NSYMS]; sp++) {
		/* is it already here? */
		if(sp->name && !strcmp(sp->name, s))
			return sp;
		if(!sp->name) { /* is it free */
			sp->name = strdup(s);
			return sp;
		}
		/* otherwise continue to next */
	}
	yyerror("Too many symbols");
	exit(1);	/* cannot continue */
} /* symlook */


void yyerror(const char *s) { std::cout << s  << line_num << col_num << std::endl; }

int main(int argc, char* argv[]) {
	FILE* file = fopen(argv[1], "r");
	int err;

  if (file) {
    yyin = file;
  } else /* error */ {
    printf("file not valid");
    return -3;
  }
	printf("%s\n", argv[1]);

	do {
		yyparse();
	} while (!feof(yyin));
}
