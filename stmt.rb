module Lox
  module Stmt
    extend AST

    Expression = define :expression
    Print      = define :expression
    Var        = define :name, :initializer
  end
end
