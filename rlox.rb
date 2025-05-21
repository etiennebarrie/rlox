require "readline"

module Lox
  extend self

  autoload :AstPrinter, "./ast_printer"
  autoload :Expr, "./expr"
  autoload :Interpreter, "./interpreter"
  autoload :Parser, "./parser"
  autoload :Scanner, "./scanner"
  autoload :Token, "./token"

  def main
    if ARGV.size > 1
      $stderr.puts "usage: rlox [script]"
      exit 64
    elsif ARGV.size == 1
      run_file ARGV.first
    else
      run_prompt
    end
  end

  def error line, message
    report line, "", message
  end

  def parser_error token, message
    if token.type == :EOF
      report token.line, " at end", message
    else
      report token.line, " at '#{token.lexeme}'", message
    end
  end

private

  def run_file path
    run File.read path
    exit 65 if @had_error
  end

  def run_prompt
    while line = Readline.readline "> " do
      run line
    end
  end

  def run source
    @had_error = false
    scanner = Scanner.new source
    parser = Parser.new scanner.scan.to_a
    expression = parser.parse
    return if @had_error
    puts AstPrinter.new.print expression
  end

  def report line, where, message
    $stderr.puts "[line %{line}] Error%{where}: %{message}" % { line:, where:, message: }
    @had_error = true
    nil
  end
end

Lox.main if $0 == __FILE__
