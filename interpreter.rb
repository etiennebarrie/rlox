module Lox
  class Interpreter
    def interpret expression
      value = evaluate expression
      puts stringify value
    rescue RuntimeError => error
      Lox.runtime_error error
    end

    def visit_Literal literal
      literal.value
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
