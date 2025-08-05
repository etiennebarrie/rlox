module Lox
  class Interpreter
    module Clock extend self
      def arity = 0
      def call(interpreter) = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second)
      def inspect = "<native fn clock>"
    end

    def initialize
      @globals = Environment.new
      @globals.declare "clock", Clock
      @environment = globals
    end

    attr_reader :globals

    def interpret statements
      statements.each do |statement|
        execute statement
      end
      self
    rescue RuntimeError => error
      Lox.runtime_error error
    end

    def visit_Literal literal
      literal.value
    end

    def visit_Logical logical
      left = evaluate logical.left
      return left if logical.operator.type == :OR && left
      return left if logical.operator.type == :AND && !left
      evaluate logical.right
    end

    def visit_Grouping grouping
      evaluate grouping.expression
    end

    def visit_Unary unary
      right = evaluate unary.right

      case unary.operator.type
      when :MINUS
        check_number_operand unary.operator, right
        -right
      when :BANG
        !right
      end
    end

    def visit_Binary binary
      left = evaluate binary.left
      right = evaluate binary.right

      case binary.operator.type
      when :MINUS
        check_number_operands binary.operator, left, right
        left - right
      when :PLUS
        unless String === left && String === right || Numeric === left && Numeric === right
          raise RuntimeError.new binary.operator, "Operands must be two numbers or two strings."
        end
        left + right
      when :SLASH
        check_number_operands binary.operator, left, right
        left / right
      when :STAR
        check_number_operands binary.operator, left, right
        left * right
      when :GREATER
        check_number_operands binary.operator, left, right
        left > right
      when :GREATER_EQUAL
        check_number_operands binary.operator, left, right
        left >= right
      when :LESS
        check_number_operands binary.operator, left, right
        left < right
      when :LESS_EQUAL
        check_number_operands binary.operator, left, right
        left <= right
      when :BANG_EQUAL
        left != right
      when :EQUAL_EQUAL
        left == right
      end
    end

    def visit_Call call
      callee = evaluate call.callee
      arguments = call.arguments.map { evaluate it }
      raise RuntimeError.new call.paren, "Can only call functions and classes." unless callee.respond_to? :call
      raise RuntimeError.new call.paren, "Expected #{callee.arity} arguments but got #{arguments.size}." unless callee.arity == arguments.size
      callee.call self, *arguments
    end

    def visit_Expression stmt
      evaluate stmt.expression
      nil
    end

    def visit_Function stmt
      function = Function.new stmt
      @environment.declare stmt.name.lexeme, function
      nil
    end

    def visit_If stmt
      if evaluate stmt.condition
        execute stmt.then_branch
      elsif stmt.else_branch
        execute stmt.else_branch
      end
      nil
    end

    def visit_Print stmt
      p evaluate stmt.expression
      nil
    end

    def visit_Return stmt
      value = evaluate stmt.value if stmt.value
      raise Return.new value
    end

    def visit_Var stmt
      value = evaluate stmt.initializer if stmt.initializer
      @environment.declare stmt.name.lexeme, value
    end

    def visit_While stmt
      while evaluate stmt.condition
        execute stmt.body
      end
      nil
    end

    def visit_Assign expr
      value = evaluate expr.value
      @environment[expr.name] = value
    end

    def visit_Variable expr
      @environment[expr.name]
    end

    def visit_Block stmt
      environment = Environment.new @environment
      execute_block stmt.statements, environment
      nil
    end

    class RuntimeError < StandardError
      def initialize token, message
        @token = token
        super message
      end

      attr_reader :token
    end

  private

    def evaluate expr
      expr.accept self
    end
    alias_method :execute, :evaluate

    public def execute_block statements, environment
      previous = @environment
      @environment = environment
      statements.each do |statement|
        execute statement
      end
    ensure
      @environment = previous
    end

    def stringify value
      case value
      when Numeric
        value.to_s.delete_suffix ".0"
      else
        value.to_s
      end
    end

    def check_number_operand operator, operand
      return if Numeric === operand
      raise RuntimeError.new operator, "Operand must be a number."
    end

    def check_number_operands operator, left, right
      return if Numeric === left && Numeric === right
      raise RuntimeError.new operator, "Operands must be numbers."
    end
  end
end
