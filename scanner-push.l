%{
  #include <iostream>
  #include <vector>
  #include <set>

  #include "parser-push.hpp"

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

  YYSTYPE yylval;
  yypstate* parserState = yypstate_new();

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
  // return IDENTIFIER;
  int status = yypush_parse(parserState, IDENTIFIER, &yylval);
  if (status != YYPUSH_MORE) {
    yypstate_delete(parserState);
    return status;
  }
}

[0-9]+("."[0-9]+)? {
  yylval.val = atof(yytext);
  yypush_parse(parserState, NUMBER, &yylval);
}

"=" {
  yylval.category = EQUALS;
  yypush_parse(parserState, EQUALS, &yylval);
}

"+" {
  yylval.category = PLUS;
  yypush_parse(parserState, PLUS, &yylval);
}

"-" {
  yylval.category = MINUS;
  yypush_parse(parserState, MINUS, &yylval);
}

"*" {
  yylval.category = TIMES;
  yypush_parse(parserState, TIMES, &yylval);
}

"/" {
  yylval.category = DIVIDEDBY;
  yypush_parse(parserState, DIVIDEDBY, &yylval);
}

";" {
  yylval.category = SEMICOLON;
  yypush_parse(parserState, SEMICOLON, &yylval);
}

"(" {
  yylval.category = LPAREN;
  yypush_parse(parserState, LPAREN, &yylval);
}

")" {
  yylval.category = RPAREN;
  yypush_parse(parserState, RPAREN, &yylval);
}

. {
  std::cerr << "Invalid symbol on line " << yylineno
    << ": " << yytext << std::endl;
  // have_error = true;
  yylval.category = yytext[0];
  yypush_parse(parserState, yytext[0], &yylval);
}

<<EOF>> {
  // if (have_error) {
  //   return 1;
  // }
  // return 0;
  int status = yypush_parse(parserState, YYEOF, NULL);
  yypstate_delete(parserState);
  return status;
}


%%

/* int main() {
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
} */
