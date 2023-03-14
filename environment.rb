require_relative './errors/ru_lox_runtime_error'
class Environment
  def initialize
    @values = {}
  end

  # @param name [String]
  # @param value [Object]
  def define(name, value)
    @values[name] = value
  end

  # @param name [Token]
  def get(name)
    return @values[name.lexeme] if @values.key?(name.lexeme)

    raise RuLoxRuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end

  # @param name [Token]
  # @param value [Object]
  def assign(name, value)
    if @values.key?(name.lexeme)
      @values[name.lexeme] = value
    else
      raise RuLoxRuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
    end
  end
end