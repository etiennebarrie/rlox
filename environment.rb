module Lox
  class Environment
    def initialize enclosing = nil
      @enclosing = enclosing
      @values = {}
    end

    def declare name, value
      @values[name] = value
    end

    def []= name, value
      if @values.key? name.lexeme
        @values[name.lexeme] = value
      elsif @enclosing
        @enclosing[name] = value
      else
        raise Interpreter::RuntimeError.new name, "Undefined variable '#{name.lexeme}'."
      end
    end

    def [] name
      @values.fetch name.lexeme do
        return @enclosing[name] if @enclosing
        raise Interpreter::RuntimeError.new name, "Undefined variable '#{name.lexeme}'."
      end
    end
  end
end
