module Lox
  class Function
    def initialize declaration
      @declaration = declaration
    end

    def call interpreter, *arguments
      environment = Environment.new interpreter.globals
      argument_with_names = @declaration.params.zip arguments
      argument_with_names.each do |param, argument|
        environment.declare param.lexeme, argument
      end
      interpreter.execute_block @declaration.body, environment
      nil
    end

    def arity = @declaration.params.size
    def inspect = "<fn #{@declaration.name.lexeme}>"
  end
end
