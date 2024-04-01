# frozen_string_literal: true

require 'lex'

# simple lex for regex the identifier and preprocessor
class Lexer < Lex::Lexer
  tokens(
    :IDENTIFIER, :PREPROCESSOR, :STRING, :CHAR
  )

  rule :newline, /\n+/ do |lexer, token|
    lexer.advance_line token.value.length
  end

  # ignore comment and preprocessor
  rule :PREPROCESSOR, /\#.*/
  rule :STRING, /\".*\"/
  rule :CHAR, /\'.*\'/

  rule :IDENTIFIER, /[_\$a-zA-Z][_\$0-9a-zA-Z]*/

  ignore " \t"

  error do |lexer, token|
  end
end
