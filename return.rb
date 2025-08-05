module Lox
  class Return < StandardError
    def initialize(value)
      super nil
      @value = value
    end

    attr_reader :value
  end
end
