module Lox
  class Function
    def initialize declaration, closure
      @declaration = declaration
      @closure = closure
    end

    def call interpreter, *arguments
      environment = Environment.new @closure
      argument_with_names = @declaration.params.zip arguments
      argument_with_names.each do |param, argument|
        environment.declare param.lexeme, argument
      end
      interpreter.execute_block @declaration.body, environment
      nil
    rescue Return => retval
      retval.value
    end

    def arity = @declaration.params.size
    def inspect = "<fn #{@declaration.name.lexeme}>"
  end
end
