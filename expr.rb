module Lox
  module Expr
    extend AST

    Binary   = define :left, :operator, :right
    Grouping = define :expression
    Literal  = define :value
    Unary    = define :operator, :right
  end
end
