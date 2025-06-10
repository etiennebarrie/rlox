module Lox
  module Expr
    extend AST

    Assign   = define :name, :value
    Binary   = define :left, :operator, :right
    Grouping = define :expression
    Literal  = define :value
    Unary    = define :operator, :right
    Variable = define :name
  end
end
