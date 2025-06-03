module Lox
  module Stmt
    extend AST

    Expression = define :expression
    Print      = define :expression
  end
end
