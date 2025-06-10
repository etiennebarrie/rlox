module Lox
  module Stmt
    extend AST

    Block      = define :statements
    Expression = define :expression
    Print      = define :expression
    Var        = define :name, :initializer
  end
end
