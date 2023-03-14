require_relative 'interpreter'
require_relative 'scanner'
require_relative './parser/parser'
require_relative './parser/ast_printer'

class RuLox
  # @param args [Array[String]] command line arguments
  def initialize(args)
    @@interpreter = Interpreter.new
    @@had_error = false
    @@had_runtime_error = false

    case args.count
    when 0
      run_prompt
    when 1
      run_file(args.first)
    else
      puts "Usage: rulox [script]"
    end
  end

  # @param file_path [String]
  def run_file(file_path)
    file_contents = File.open(file_path).read
    run(file_contents)

    # don't actually execute the file if there is an error in it
    exit(65) if @@had_error
    exit(70) if @@had_runtime_error
  end

  def run_prompt
    puts "type 'exit' (without quotes) to exit"
    puts "now reading input..."
    while true 
      print '> '
      input = $stdin.gets.chomp
      break if input == "exit"

      puts "> #{input}"
      begin
        run(input)
      rescue
      end

      # reset error handling while in the interactive mode
      # we don't want a single typed error to kill an
      # interactive session
      @@had_error = false

      # we don't really care about runtime errors in the REPL. If it
      # errors, we just give them a new line and keep going.
      @@had_runtime_error = false
    end
  end

  # @param source [String]
  def run(source)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    parser = Parser.new(tokens)
    statements = parser.parse

    # stop if there was a syntax error
    return if @@had_error

    @@interpreter.interpret(statements)

    # use this printer to get an look into internals
    # ast_printer = AstPrinter.new
    # ast_printer.print(expression)
  end

  # @param line [Integer]
  # @param message [String]
  def self.error(line, message)
    report(line, "", message)
  end

  # @param token [Token]
  # @param message [String]
  def self.parse_error(token, message)
    where = token.type == TokenType::EOF ? "at end" :  "at '#{token.lexeme}'"

    report(token.line, where, message)
  end

  # @param error [RuLoxRuntimeError]
  def self.runtime_error(error)
    token = error.token
    where = token.type == TokenType::EOF ? "at end" :  "at '#{token.lexeme}'"

    puts "[line #{token.line}] Error #{where}: #{error.message}"
    @@had_runtime_error = true
  end

  # @param line [Integer]
  # @param where [String]
  # @param message [String]
  def self.report(line, where, message)
    puts "[line #{line}] Error #{where}: #{message}"

    @@had_error = true
  end
end

RuLox.new(ARGV)
