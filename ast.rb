module Lox
  module AST
    def define *attributes
      klass = Data.define(*attributes)
      klass.include self
    end

    def const_added const_name
      constant = const_get const_name
      constant.define_method :accept do |visitor|
        visitor.public_send :"visit_#{const_name}", self
      end
    end
  end
end
