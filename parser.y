%{
    #include <iostream>
    #include <map>

    std::map<std::string, float> symbols;

    void yyerror(const char* err);
    extern int yylex();
%}

/* %define api.value.type { std::string* } */
%union {
    float val;
    int category;
    std::string* str;
}

%token <str> IDENTIFIER
%token <val> NUMBER
%token <category> EQUALS PLUS MINUS TIMES DIVIDEDBY
%token <category> SEMICOLON LPAREN RPAREN

%type <val> expression

%left PLUS MINUS
%left TIMES DIVIDEDBY
/* %right  */
/* %nonassoc */

%start program

%%

program
    : program statement
    | statement
    ;

statement
    : IDENTIFIER EQUALS expression SEMICOLON
    ;

expression
    : LPAREN expression RPAREN
    | expression PLUS expression
    | expression MINUS expression
    | expression TIMES expression
    | expression DIVIDEDBY expression
    | NUMBER
    | IDENTIFIER
    ;

%%
