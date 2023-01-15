class RuLox
  def initialize(file_paths)
    case file_paths.count
    when 0
      run_prompt
    when 1
      run_file(file_paths.first)
    else
      puts "Usage: rulox [script]"
    end
  end

  def run_file(path)
    puts "this is the file path"
  end

  def run_prompt
    puts "now reading input..."
    input = ''
    until input == 'exit'
      input = $stdin.gets

      puts "> #{input}"
    end
  end
end

RuLox.new(ARGV)