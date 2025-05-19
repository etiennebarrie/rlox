module Lox
  module Expr
    def self.define *attributes = Data.define(*attributes).include self

    Binary   = define :left, :operator, :right
    Grouping = define :expression
    Literal  = define :value
    Unary    = define :operator, :right
  end
end
