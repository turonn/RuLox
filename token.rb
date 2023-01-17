class Token
  attr_reader :type, :lexeme, :literal, :line
  # @param type [TokenType]
  # @param lexeme [String] how it's spelled
  # @param literal [BasicObject] the actual thing
  # @param line [Integer]
  def initialize(type, lexeme, literal, line)
    @type = type
    @lexeme = lexeme
    @literal = literal
    @line = line
  end

  def to_string
    type + ' ' + lexeme + ' ' + literal
  end
end