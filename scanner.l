%{
  #include <iostream>
  #include <vector>
  #include <set>

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
  save_token(yytext, "IDENTIFIER");
  ids.insert(yytext);
}

[0-9]+("."[0-9]+)? {
  save_token(yytext, "NUMBER");
}

"=" {
  save_token(yytext, "EQUALS");
}

"+" {
  save_token(yytext, "PLUS");
}

"-" {
  save_token(yytext, "MINUS");
}

"*" {
  save_token(yytext, "TIMES");
}

"/" {
  save_token(yytext, "DIVIDEDBY");
}

";" {
  save_token(yytext, "SEMICOLON");
}

"(" {
  save_token(yytext, "LPAREN");
}

")" {
  save_token(yytext, "RPAREN");
}

. {
  std::cerr << "Invalid symbol on line " << yylineno
    << ": " << yytext << std::endl;
  have_error = true;
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
