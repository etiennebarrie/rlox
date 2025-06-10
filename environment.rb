module Lox
  class Environment
    def initialize
      @values = {}
    end

    def declare name, value
      @values[name] = value
    end

    def [] name
      @values.fetch name.lexeme do
        raise Interpreter::RuntimeError.new name, "Undefined variable '#{name.lexeme}'."
      end
    end
  end
end
