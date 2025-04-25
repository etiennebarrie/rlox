module Lox
  class Scanner
    def initialize source
      @source = source
      @start = 0
      @current = 0
      @line = 1
    end

    def scan
      until end?
        @start = @current
        token = scan_token
        yield token if token
      end
      self
    end

  private
    def end? = @current >= @source.size

    def scan_token
      case c = advance
      when "(" then add_token :LEFT_PAREN
      when ")" then add_token :RIGHT_PAREN
      when "{" then add_token :LEFT_BRACE
      when "}" then add_token :RIGHT_BRACE
      when "," then add_token :COMMA
      when "." then add_token :DOT
      when "-" then add_token :MINUS
      when "+" then add_token :PLUS
      when ";" then add_token :SEMICOLON
      when "*" then add_token :STAR
      when "!" then add_token match?("=") ? :BANG_EQUAL    : :BANG
      when "=" then add_token match?("=") ? :EQUAL_EQUAL   : :EQUAL
      when "<" then add_token match?("=") ? :LESS_EQUAL    : :LESS
      when ">" then add_token match?("=") ? :GREATER_EQUAL : :GREATER
      when "/"
        if match? "/"
          advance while peek != "\n" && !end?
        else
          add_token :SLASH
        end
      when " ", "\r", "\t"
      when "\n" then new_line
      when '"' then string
      else
        if digit? c
          number
        elsif alpha? c
          identifier
        else
          Lox.error @line, "Unexpected character #{c.inspect}"
        end
      end
    end

    def advance
      @source[@current].tap do
        @current += 1
      end
    end

    def peek
      if end?
        "\0"
      else
        @source[@current]
      end
    end

    def peek_next
      if @current + 1 >= @source.size
        "\0"
      else
        @source[@current + 1]
      end
    end

    def new_line
      @line += 1
      nil
    end

    def match? expected
      return false if end?
      return false if @source[@current] != expected
      @current += 1
      true
    end

    def add_token type, literal = nil
      text = @source[@start...@current]
      Token.new type, text, literal, @line
    end

    def string
      while peek != '"' && !end?
        new_line if peek == "\n"
        advance
      end
      Lox.error @line, "Unterminated string: #{@source[@start..]}" if end?
      advance # consume closing "
      value = @source[@start + 1...@current - 1]
      add_token :STRING, value
    end

    def digit? c
      c.between? "0", "9"
    end

    def number
      advance while digit? peek
      if peek == "." && digit?(peek_next)
        advance
        advance while digit? peek
      end
      add_token :NUMBER, @source[@start...@current].to_f
    end

    def alpha? c
      c.between? "a", "z" or c.between? "A", "Z" or c == "_"
    end

    def alphanumeric? c
      alpha? c or digit? c
    end

    IDENTIFIER_TYPE = {
      "and"    => :AND,
      "class"  => :CLASS,
      "else"   => :ELSE,
      "false"  => :FALSE,
      "for"    => :FOR,
      "fun"    => :FUN,
      "if"     => :IF,
      "nil"    => :NIL,
      "or"     => :OR,
      "print"  => :PRINT,
      "return" => :RETURN,
      "super"  => :SUPER,
      "this"   => :THIS,
      "true"   => :TRUE,
      "var"    => :VAR,
      "while"  => :WHILE,
    }
    IDENTIFIER_TYPE.default = :IDENTIFIER
    private_constant :IDENTIFIER_TYPE

    def identifier
      advance while alphanumeric? peek
      text = @source[@start...@current]
      add_token IDENTIFIER_TYPE[text]
    end
  end
end
