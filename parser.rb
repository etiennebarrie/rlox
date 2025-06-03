module Lox
  class Parser
    class ParseError < StandardError
    end

    def initialize tokens
      @tokens = tokens
      @current = 0
    end

    def parse
      statements = []
      until end?
        statements << statement
      end
      statements
    rescue ParseError
    end

  private

    def statement
      if match? :PRINT
        print_statement
      else
        expression_statement
      end
    end

    def print_statement
      value = expression
      consume :SEMICOLON, "Expect ';' after value."
      Stmt::Print.new value
    end

    def expression_statement
      expr = expression
      consume :SEMICOLON, "Expect ';' after expression."
      Stmt::Expression.new expr
    end

    def expression = equality

    def equality
      expr = comparison
      while match? :BANG_EQUAL, :EQUAL_EQUAL
        operator = previous
        right = comparison
        expr = Expr::Binary.new expr, operator, right
      end
      expr
    end

    def comparison
      expr = term
      while match? :GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL
        operator = previous
        right = term
        expr = Expr::Binary.new expr, operator, right
      end
      expr
    end

    def term
      expr = factor
      while match? :MINUS, :PLUS
        operator = previous
        right = factor
        expr = Expr::Binary.new expr, operator, right
      end
      expr
    end

    def factor
      expr = unary
      while match? :SLASH, :STAR
        operator = previous
        right = unary
        expr = Expr::Binary.new expr, operator, right
      end
      expr
    end

    def unary
      if match? :BANG, :MINUS
        operator = previous
        right = unary
        return Expr::Unary.new operator, right
      end
      primary
    end

    def primary
      return Expr::Literal.new false if match? :FALSE
      return Expr::Literal.new true if match? :TRUE
      return Expr::Literal.new nil if match? :NIL
      return Expr::Literal.new previous.literal if match? :NUMBER, :STRING
      if match? :LEFT_PAREN
        expr = expression
        consume :RIGHT_PAREN, "Expect ')' after expression."
        return Expr::Grouping.new expr
      end
      raise error peek, "Expect expression."
    end

    def match? *token_types
      if token_types.any? { |token_type| check? token_type }
        advance
        true
      end
    end

    def check? token_type
      return false if end?
      peek.type == token_type
    end

    def advance
      @current += 1 unless end?
      previous
    end

    def consume token_type, error_message
      return advance if check? token_type
      raise error peek, error_message
    end

    def error token, error_message
      Lox.parser_error token, error_message
      ParseError.new
    end

    def synchronize
      advance
      until end?
        return if previous.type == :SEMICOLON
        case peek.type
        when :CLASS, :FUN, :VAR, :FOR, :IF, :WHILE, :PRINT, :RETURN
          return
        end
        advance
      end
    end

    def end? = peek.type == :EOF
    def peek = @tokens[@current]
    def previous = @tokens[@current - 1]
  end
end
