require "readline"

module Lox
  extend self

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
    scanner.scan do |token|
      p token
    end
  end
end

Lox.main
