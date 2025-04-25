module Lox
  class Token
    TYPES = \
      # Single-character tokens.
      %i[ LEFT_PAREN RIGHT_PAREN LEFT_BRACE RIGHT_BRACE COMMA DOT MINUS PLUS SEMICOLON SLASH STAR ] +
      # One or two character tokens.
      %i[ BANG BANG_EQUAL EQUAL EQUAL_EQUAL GREATER GREATER_EQUAL LESS LESS_EQUAL ] +
      # Literals.
      %i[ IDENTIFIER STRING NUMBER ] +
      # Keywords.
      %i[ AND CLASS ELSE FALSE FUN FOR IF NIL OR PRINT RETURN SUPER THIS TRUE VAR WHILE ] +
      %i[ EOF ]
    private_constant :TYPES
  end
end
