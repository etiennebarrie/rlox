module Lox
  module Stmt
    extend AST

    Block      = define :statements
    Expression = define :expression
    If         = define :condition, :then_branch, :else_branch
    Print      = define :expression
    Var        = define :name, :initializer
  end
end
