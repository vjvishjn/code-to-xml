%{
#include <iostream>
#include <cstring>
#include "y.tab.h"
#include <math.h>
#include "parser.h"
using namespace std;

int line_num = 1;
int col_num = 1;
int prev_col = 0;
int start_line = 0;
int start_col = 0;
int end_col = 0;
int prev_line = -1;
int prev_tok_line;


int char_count(char* text, char ch){
	int i;
	int count = 0;
	for (i = 0; i < strlen(text); ++i)
	{
		if(text[i] == ch){
			count++;
		}
	}
	return count;
}

void printLines(char *text, int &col_num, int &prev_col, int start_line){
	prev_tok_line = prev_line;
	prev_line = start_line;
	printf("Token: \"%s\"\t=> Line: %d StartColumn: %d ", text, start_line, col_num);
	if (col_num != 1)
		prev_col = col_num;
	col_num += strlen(text);
	printf("EndColumn: %d\n", col_num-1);
}

%}

EXP											(e|E)[+-]?[0-9]+
ID 											[_a-zA-Z][_a-zA-Z0-9]*
INT_CONST 							([1-9][0-9]*|[0]+)
FLOAT_CONST 						(([0-9]+)?\.[0-9]+|[0-9]+\.)([Ee][+-]?[0-9]+)?|[0-9][Ee][+-]?[0-9]+
CHARAC									[\']([^\'\\\n]|\\\'|\\\"|\\\?|\\\\|\\a|\\b|\\f|\\n|\\r|\\t|\\v)+[\']
STRING_CONST						[\"]([^\"\\\n]|\\\'|\\\"|\\\?|\\\\|\\a|\\b|\\f|\\n|\\r|\\t|\\v)*[\"]
COMMENTS2								[\/][\/][^\n]*
COMMENTS1 							([\/][\*](([^\*])|((\*)+[^\/\*]))*[\*][\/])
PREPROCESSORDIRECTIVE		#.*
%%

{PREPROCESSORDIRECTIVE}		{}
"auto"		{ printLines(yytext, col_num, prev_col, line_num); return AUTO; }
"break"		{ printLines(yytext, col_num, prev_col, line_num); return BREAK; }
"case"		{ printLines(yytext, col_num, prev_col, line_num); return CASE; }
"char"		{ printLines(yytext, col_num, prev_col, line_num); return CHAR; }
"const"		{ printLines(yytext, col_num, prev_col, line_num); return CONST; }
"continue"	{ printLines(yytext, col_num, prev_col, line_num); return CONTINUE; }
"default"	{ printLines(yytext, col_num, prev_col, line_num); return DEFAULT; }
"do"		{ printLines(yytext, col_num, prev_col, line_num); return DO; }
"double"	{ printLines(yytext, col_num, prev_col, line_num); return DOUBLE; }
"else"		{ printf("ElseStatement:\t=> StartLine: %d StartColumn: %d\n", line_num, col_num); printLines(yytext, col_num, prev_col, line_num); return ELSE; }
"enum"		{ printLines(yytext, col_num, prev_col, line_num); return ENUM; }
"extern"	{ printLines(yytext, col_num, prev_col, line_num); return EXTERN; }
"float"		{ printLines(yytext, col_num, prev_col, line_num); return FLOAT; }
"for"		{ printf("ForStartStatement:\t=> StartLine: %d StartColumn: %d\n", line_num, col_num); printLines(yytext, col_num, prev_col, line_num); return FOR;}
"goto"		{ printLines(yytext, col_num, prev_col, line_num); return GOTO; }
"if"		{ printf("IfStatementStart:\t=> StartLine: %d StartColumn: %d\n", line_num, col_num); printLines(yytext, col_num, prev_col, line_num); return IF;}
"inline"	{ printLines(yytext, col_num, prev_col, line_num); return INLINE; }
"int"		{ printLines(yytext, col_num, prev_col, line_num); return INT; }
"long"		{ printLines(yytext, col_num, prev_col, line_num); return LONG; }
"register"	{ printLines(yytext, col_num, prev_col, line_num); return REGISTER; }
"restrict"	{ printLines(yytext, col_num, prev_col, line_num); return RESTRICT; }
"return"	{ printLines(yytext, col_num, prev_col, line_num); return RETURN; }
"short"		{ printLines(yytext, col_num, prev_col, line_num); return SHORT; }
"signed"	{ printLines(yytext, col_num, prev_col, line_num); return SIGNED; }
"sizeof"	{ printLines(yytext, col_num, prev_col, line_num); return SIZEOF; }
"static"	{ printLines(yytext, col_num, prev_col, line_num); return STATIC; }
"struct"	{ printLines(yytext, col_num, prev_col, line_num); return STRUCT; }
"switch"	{ printf("SwitchStatement:\t=> StartLine: %d StartColumn: %d\n", line_num, col_num); printLines(yytext, col_num, prev_col, line_num); return SWITCH;}
"typedef"	{ printLines(yytext, col_num, prev_col, line_num); return TYPEDEF; }
"union"		{ printLines(yytext, col_num, prev_col, line_num); return UNION; }
"using"     { printLines(yytext, col_num, prev_col, line_num); return USING; }
"namespace"	{ printLines(yytext, col_num, prev_col, line_num); return NAMESPACE; }
"std"       { printLines(yytext, col_num, prev_col, line_num); return STD; }
"unsigned"	{ printLines(yytext, col_num, prev_col, line_num); return UNSIGNED; }
"void"		{ printLines(yytext, col_num, prev_col, line_num); return VOID; }
"volatile"	{ printLines(yytext, col_num, prev_col, line_num); return VOLATILE; }
"while"		{ printf("WhileStatementStart:\t=> StartLine: %d StartColumn: %d\n", line_num, col_num); printLines(yytext, col_num, prev_col, line_num); return WHILE;}
"_Bool"		{ printLines(yytext, col_num, prev_col, line_num); return _BOOL; }
"_Complex"	{ printLines(yytext, col_num, prev_col, line_num); return _COMPLEX; }
"_Imaginary"	{ printLines(yytext, col_num, prev_col, line_num); return _IMAGINARY; }


"("		{ printLines(yytext, col_num, prev_col, line_num); return LPARAN; }
")"		{ printLines(yytext, col_num, prev_col, line_num); return RPARAN; }
"{"		{ printLines(yytext, col_num, prev_col, line_num); return LBRACE; }
"}"		{ printLines(yytext, col_num, prev_col, line_num); return RBRACE; }
"["		{ printLines(yytext, col_num, prev_col, line_num); return LBRACKET; }
"]"		{ printLines(yytext, col_num, prev_col, line_num); return RBRACKET; }

"+"		{ printLines(yytext, col_num, prev_col, line_num); return ADD_OP; }
"-"		{ printLines(yytext, col_num, prev_col, line_num); return SUB_OP; }
"*"		{ printLines(yytext, col_num, prev_col, line_num); return MULT_OP; }
"/"		{ printLines(yytext, col_num, prev_col, line_num); return DIV_OP; }
"%"		{ printLines(yytext, col_num, prev_col, line_num); return MODULO_OP; }

"<<"	{ printLines(yytext, col_num, prev_col, line_num); return LSHIFT_OP; }
">>"	{ printLines(yytext, col_num, prev_col, line_num); return RSHIFT_OP; }

"<"		{ printLines(yytext, col_num, prev_col, line_num); return LESS_OP; }
">"		{ printLines(yytext, col_num, prev_col, line_num); return GREATER_OP; }
"<="	{ printLines(yytext, col_num, prev_col, line_num); return LEQ_OP; }
">="	{ printLines(yytext, col_num, prev_col, line_num); return GEQ_OP; }
"=="	{ printLines(yytext, col_num, prev_col, line_num); return EQ_OP; }
"!="	{ printLines(yytext, col_num, prev_col, line_num); return NEQ_OP; }

"++"	{ printLines(yytext, col_num, prev_col, line_num); return INC_OP; }
"--"	{ printLines(yytext, col_num, prev_col, line_num); return DEC_OP; }

"!"		{ printLines(yytext, col_num, prev_col, line_num); return LOGICAL_NEG_OP; }
"&&"	{ printLines(yytext, col_num, prev_col, line_num); return LOGICAL_AND_OP; }
"||"	{ printLines(yytext, col_num, prev_col, line_num); return LOGICAL_OR_OP; }

"~"		{ printLines(yytext, col_num, prev_col, line_num); return BIT_NOT_OP; }
"&"		{ printLines(yytext, col_num, prev_col, line_num); return BIT_AND_OP; }
"|"		{ printLines(yytext, col_num, prev_col, line_num); return BIT_OR_OP; }
"^"		{ printLines(yytext, col_num, prev_col, line_num); return BIT_XOR_OP; }

"="		{ printLines(yytext, col_num, prev_col, line_num); return ASSIGN_OP; }
"+="	{ printLines(yytext, col_num, prev_col, line_num); return ADD_ASSIGN_OP; }
"-="	{ printLines(yytext, col_num, prev_col, line_num); return SUB_ASSIGN_OP; }
"*="	{ printLines(yytext, col_num, prev_col, line_num); return MULT_ASSIGN_OP; }
"/="	{ printLines(yytext, col_num, prev_col, line_num); return DIV_ASSIGN_OP; }
"%="	{ printLines(yytext, col_num, prev_col, line_num); return MODULO_ASSIGN_OP; }

"&="	{ printLines(yytext, col_num, prev_col, line_num); return BIT_AND_ASSIGN_OP; }
"|="	{ printLines(yytext, col_num, prev_col, line_num); return BIT_OR_ASSIGN_OP; }
"^="	{ printLines(yytext, col_num, prev_col, line_num); return BIT_XOR_ASSIGN_OP; }
"<<="	{ printLines(yytext, col_num, prev_col, line_num); return BIT_LSHIFT_ASSIGN_OP; }
">>="	{ printLines(yytext, col_num, prev_col, line_num); return BIT_RSHIFT_ASSIGN_OP; }

"?"		{ printLines(yytext, col_num, prev_col, line_num); return QUESTIONMARK_OP; }
":"		{ printLines(yytext, col_num, prev_col, line_num); return COLON; }
","		{ printLines(yytext, col_num, prev_col, line_num); return COMMA; }

";"		{ printLines(yytext, col_num, prev_col, line_num); return SEMICOLON; }
"..."	{ printLines(yytext, col_num, prev_col, line_num); return ELLIPSES; }
"#"		{ printLines(yytext, col_num, prev_col, line_num); return HASH; }
"."		{ printLines(yytext, col_num, prev_col, line_num); return DOT_OP; }
"->"	{ printLines(yytext, col_num, prev_col, line_num); return STRUCT_REFERENCE; }


{INT_CONST}			{ yylval.intval = atoi(yytext); printLines(yytext, col_num, prev_col, line_num); return INT_CONST;}

{FLOAT_CONST}		{ yylval.dval = atof(yytext); printLines(yytext, col_num, prev_col, line_num); return FLOAT_CONST;}

{STRING_CONST}  { yylval.sval = strdup(yytext); printLines(yytext, col_num, prev_col, line_num); return STRING_CONST;}

{COMMENTS1}		{
								int lines = char_count(strdup(yytext),'\n');
								line_num += lines;
							}
{COMMENTS2}	;/* ignore comment */


[ \t]	  	 {
						if(yytext[0] == ' '){
							col_num += 1;
						}
						else {
							col_num += 4;
						}
					}

\n				{
						if(col_num != 1){
							prev_col = col_num;
						}
						++line_num;
						col_num = 1;
					}

{ID}		  {
						yylval.symp = symlook(yytext);
						start_line = line_num;
						start_col = col_num;
						printLines(yytext, col_num, prev_col, line_num);
						end_col = col_num;
						return ID;
          }

"$"	{ col_num += strlen(yytext); return 0; /* end of input */ }

%%
