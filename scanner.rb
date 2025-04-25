module Lox
  class Scanner
    def initialize source
      @source = source
      @start = 0
      @current = 0
      @line = 1
    end

    def scan
      until end?
        @start = @current
        yield scan_token
      end
      self
    end

  private
    def end? = @current >= @source.size

  end
end
