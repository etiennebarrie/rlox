module Lox
  class Interpreter
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
        left - right
      when :PLUS
        left + right
      when :SLASH
        left / right
      when :STAR
        left * right
      when :GREATER
        left > right
      when :GREATER_EQUAL
        left >= right
      when :LESS
        left < right
      when :LESS_EQUAL
        left <= right
      when :BANG_EQUAL
        left != right
      when :EQUAL_EQUAL
        left == right
      end
    end

  private

    def evaluate expr
      expr.accept self
    end
  end
end
