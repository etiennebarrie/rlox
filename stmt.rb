module Lox
  module Stmt
    extend AST

    Block      = define :statements
    Expression = define :expression
    Function   = define :name, :params, :body
    If         = define :condition, :then_branch, :else_branch
    Print      = define :expression
    Var        = define :name, :initializer
    While      = define :condition, :body
  end
end
