%{
  #include <iostream>
  #include <vector>
  #include <set>

  #include "parser.hpp"

  struct token {
    std::string lexeme;
    std::string category;
  };

  std::vector<struct token> tokens;
  std::set<std::string> ids;
  bool have_error = false;

  void save_token(const std::string& lexeme, const std::string& category) {
    struct token token = { .lexeme = lexeme, .category = category };
    tokens.push_back(token);
  }

%}

%option noyywrap
%option yylineno

%%

%{
  /* No code to put at the top of yylex(). */
%}

[ \t\n]*      /* Ignore whitespace. */

[a-z][0-9]? {
  // save_token(yytext, "IDENTIFIER");
  // ids.insert(yytext);
  yylval.str = new std::string(yytext, yyleng);
  return IDENTIFIER;
}

[0-9]+("."[0-9]+)? {
  yylval.val = atof(yytext);
  return NUMBER;
}

"=" {
  yylval.category = EQUALS;
  return EQUALS;
}

"+" {
  yylval.category = PLUS;
  return PLUS;
}

"-" {
  yylval.category = MINUS;
  return MINUS;
}

"*" {
  yylval.category = TIMES;
  return TIMES;
}

"/" {
  yylval.category = DIVIDEDBY;
  return DIVIDEDBY;
}

";" {
  yylval.category = SEMICOLON;
  return SEMICOLON;
}

"(" {
  yylval.category = LPAREN;
  return LPAREN;
}

")" {
  yylval.category = RPAREN;
  return RPAREN;
}

. {
  std::cerr << "Invalid symbol on line " << yylineno
    << ": " << yytext << std::endl;
  // have_error = true;
  yylval.category = yytext[0];
  return yytext[0];
}

<<EOF>> {
  if (have_error) {
    return 1;
  }
  return 0;
}


%%

int main() {
  if (!yylex()) {
    for (int i = 0; i < tokens.size(); i++) {
      std::cout << tokens[i].lexeme << "\t\t" << tokens[i].category
        << std::endl;
    }

    std::cout << std::endl << "Identifiers:" << std::endl;
    std::set<std::string>::iterator iit;
    for (iit = ids.begin(); iit != ids.end(); ++iit) {
      std::cout << *iit << std::endl;
    }
  }
}
