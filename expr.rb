module Lox
  module Expr
    def self.define *attributes = Data.define(*attributes).include self

    Binary   = define :left, :operator, :right
    Grouping = define :expression
    Literal  = define :value
    Unary    = define :operator, :right

    def accept visitor
      visitor.public_send :"visit_#{self.class.name.delete_prefix "Lox::Expr::"}", self
    end
  end
end
