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
%token <category> IF ELSE COLON

%type <val> expression

%left PLUS MINUS
%left TIMES DIVIDEDBY
/* %right  */
/* %nonassoc */

%start program

%define parse.error verbose

%%

program
    : program statement
    | statement
    ;

statement
    : assignmentStatement
    | ifStatement
    ;

assignmentStatement
    : IDENTIFIER EQUALS expression SEMICOLON { symbols[*$1] = $3; delete $1; }
    ;

ifStatement
    : IF expression COLON statement
    | IF expression COLON closedStatement ELSE COLON statement
    ;

closedStatement
    : assignmentStatement
    | IF expression COLON closedStatement ELSE COLON closedStatement
    ;

expression
    : LPAREN expression RPAREN { $$ = $2; }
    | expression PLUS expression { $$ = $1 + $3; }
    | expression MINUS expression { $$ = $1 - $3; }
    | expression TIMES expression { $$ = $1 * $3; }
    | expression DIVIDEDBY expression { $$ = $1 / $3; }
    | NUMBER { $$ = $1; }
    | IDENTIFIER { $$ = symbols[*$1]; delete $1; }
    ;

%%

void yyerror(const char* err) {
    std::cerr << "Error: " << err << std::endl;
}

int main() {
    if (!yyparse()) {
        std::map<std::string, float>::iterator it;
        for (it = symbols.begin(); it != symbols.end(); it++) {
            std::cout << it->first << " : " << it->second << std::endl;
        }
        return 0;
    } else {
        return 1;
    }
}
