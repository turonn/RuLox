class RuLox
  # @param args [Array[String]] command line arguments
  def initialize(args)
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
    puts "this is the file path"
    file_contents = File.open(file_path).read

    # raise some sort of error here if we cannot find the file

    run(file_contents)
  end

  def run_prompt
    puts "type 'exit' (without quotes) to exit"
    puts "now reading input..."
    while true 
      input = $stdin.gets
      break if input == "exit\n"

      puts "> #{input}"
      run(input)
    end
  end

  # @param source [String]
  def run(source)
    puts source.inspect
  end
end

RuLox.new(ARGV)