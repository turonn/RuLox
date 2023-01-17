require_relative 'scanner'

class RuLox
  # @param args [Array[String]] command line arguments
  def initialize(args)
    @@had_error = false

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
  end

  def run_prompt
    puts "type 'exit' (without quotes) to exit"
    puts "now reading input..."
    while true 
      print '> '
      input = $stdin.gets.chomp
      break if input == "exit"

      puts "> #{input}"
      run(input)

      # reset error handling while in the interactive mode
      # we don't want a single typed error to kill an
      # interactive session
      @@had_error = false
    end
  end

  # @param source [String]
  def run(source)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    tokens.each do |token|
      puts token.inspect
    end
  end

  # @param line [Integer]
  # @param message [String]
  def self.error(line, message)
    report(line, "", message)
  end

  # @param line [Integer]
  # @param where [String]
  # @param message [String]
  def self.report(line, where, message)
    puts "[line #{line}] Error #{where} + #{message}"

    @@had_error = true
  end
end

RuLox.new(ARGV)
