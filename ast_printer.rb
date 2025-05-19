module Lox
  class AstPrinter
    def print expr
      expr.accept self
    end

    def visit_Binary binary
      parenthesize binary.operator.lexeme, binary.left, binary.right
    end

    def visit_Grouping grouping
      parenthesize "group", grouping.expression
    end

    def visit_Literal literal
      if literal.value.nil?
        "nil"
      else
        literal.value.to_s
      end
    end

    def visit_Unary unary
      parenthesize unary.operator.lexeme, unary.right
    end

  private

    def parenthesize name, *exprs
      "(#{name}#{exprs.map { |expr| " #{expr.accept self}" }.join})"
    end
  end
end
