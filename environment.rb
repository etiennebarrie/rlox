module Lox
  class Environment
    def initialize
      @values = {}
    end

    def declare name, value
      @values[name] = value
    end

    def []= name, value
      if @values.key? name.lexeme
        @values[name.lexeme] = value
      else
        raise Interpreter::RuntimeError.new name, "Undefined variable '#{name.lexeme}'."
      end
    end

    def [] name
      @values.fetch name.lexeme do
        raise Interpreter::RuntimeError.new name, "Undefined variable '#{name.lexeme}'."
      end
    end
  end
end
