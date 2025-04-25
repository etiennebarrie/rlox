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
      else
        Lox.error @line, "Unexpected character #{c.inspect}"
      end
    end

    def advance
      @source[@current].tap do
        @current += 1
      end
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
  end
end
