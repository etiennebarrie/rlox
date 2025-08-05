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
        statements << declaration
      end
      statements
    rescue ParseError
    end

  private

    def declaration
      if match? :VAR
        var_declaration
      elsif match? :FUN
        function "function"
      else
        statement
      end
    rescue ParseError
      synchronize
    end

    def function kind
      name = consume :IDENTIFIER, "Expect #{kind} name."
      consume :LEFT_PAREN, "Expect '(' after #{kind} name."
      params = []
      unless check? :RIGHT_PAREN
        begin
          error peek, "Can't have more than 255 parameters." if params.size >= 255
          param = consume :IDENTIFIER, "Expect parameter name."
          params << param
        end while match? :COMMA
      end
      consume :RIGHT_PAREN, "Expect ')' after parameters."
      consume :LEFT_BRACE, "Expect '{' before #{kind} body"
      body = block
      Stmt::Function.new name, params, body
    end

    def var_declaration
      name = consume :IDENTIFIER, "Expect variable name."
      initializer = expression if match? :EQUAL
      consume :SEMICOLON, "Expect ';' after variable declaration."
      Stmt::Var.new name, initializer
    end

    def statement
      if match? :IF
        if_statement
      elsif match? :PRINT
        print_statement
      elsif match? :RETURN
        return_statement
      elsif match? :WHILE
        while_statement
      elsif match? :FOR
        for_statement
      elsif match? :LEFT_BRACE
        Stmt::Block.new block
      else
        expression_statement
      end
    end

    def if_statement
      consume :LEFT_PAREN, "Expect '(' after 'if'."
      condition = expression
      consume :RIGHT_PAREN, "Expect ')' after if condition."
      then_branch = statement
      else_branch = statement if match? :ELSE
      Stmt::If.new condition, then_branch, else_branch
    end

    def print_statement
      value = expression
      consume :SEMICOLON, "Expect ';' after value."
      Stmt::Print.new value
    end

    def return_statement
      keyword = previous
      value = nil
      unless check? :SEMICOLON
        value = expression
      end
      consume :SEMICOLON, "Expect ';' after return value."
      Stmt::Return.new keyword, value
    end

    def while_statement
      consume :LEFT_PAREN, "Expect '(' after 'while'."
      condition = expression
      consume :RIGHT_PAREN, "Expect ')' after while condition."
      body = statement
      Stmt::While.new condition, body
    end

    def for_statement
      consume :LEFT_PAREN, "Expect '(' after 'for'."
      if match? :SEMICOLON
      elsif match? :VAR
        initializer = var_declaration
      else
        initializer = expression
      end
      condition = expression unless check? :SEMICOLON
      consume :SEMICOLON, "Expect ';' after loop condition."
      increment = expression unless check? :RIGHT_PAREN
      consume :RIGHT_PAREN, "Expect ')' after for clauses."
      body = statement
      if increment
        increment = Stmt::Expression.new increment
        body = Stmt::Block.new [body, increment]
      end
      condition ||= Expr::Literal.new true
      body = Stmt::While.new condition, body
      body = Stmt::Block.new [initializer, body] if initializer
      body
    end

    def block
      statements = []
      until check? :RIGHT_BRACE or end?
        statements << declaration
      end
      consume :RIGHT_BRACE, "Expect '}' after block."
      statements
    end

    def expression_statement
      expr = expression
      consume :SEMICOLON, "Expect ';' after expression."
      Stmt::Expression.new expr
    end

    def expression = assignment

    def assignment
      expr = logic_or
      if match? :EQUAL
        equals = previous
        value = assignment
        if Expr::Variable === expr
          name = expr.name
          return Expr::Assign.new name, value
        end
        error equals, "Invalid assignment target."
      end
      expr
    end

    def logic_or
      expr = logic_and
      while match? :OR
        operator = previous
        right = logic_and
        expr = Expr::Logical.new expr, operator, right
      end
      expr
    end

    def logic_and
      expr = equality
      while match? :AND
        operator = previous
        right = equality
        expr = Expr::Logical.new expr, operator, right
      end
      expr
    end

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
      call
    end

    def call
      expr = primary
      if match? :LEFT_PAREN
        args = arguments
        paren = consume :RIGHT_PAREN, "Expect ')' after arguments."
        expr = Expr::Call.new expr, paren, args
      end
      expr
    end

    def arguments
      return [] if check? :RIGHT_PAREN
      args = [expression]
      while match? :COMMA
        error peek, "Can't have more than 255 arguments." if args.size >= 255
        args << expression
      end
      args
    end

    def primary
      return Expr::Literal.new false if match? :FALSE
      return Expr::Literal.new true if match? :TRUE
      return Expr::Literal.new nil if match? :NIL
      return Expr::Literal.new previous.literal if match? :NUMBER, :STRING
      return Expr::Variable.new previous if match? :IDENTIFIER
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
