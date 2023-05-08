require_relative './errors/ru_lox_runtime_error'
class Environment
  attr_reader :enclosing
  attr_accessor :values

  def initialize(enclosing = nil)
    @values = {}
    @enclosing = enclosing
  end

  # @param name [String]
  # @param value [Object]
  def define(name, value)
    @values[name] = value
  end

  # @param name [Token]
  def get(name)
    return @values[name.lexeme] if @values.key?(name.lexeme)

    # look to see if the variable is defined at a higher scope
    return @enclosing.get(name) unless @enclosing.nil?

    raise RuLoxRuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end

  # @param distance [Integer]
  # @param name [String]
  def get_at(distance, name)
    _ancestor(distance).values[name]
  end

  # @param name [Token]
  # @param value [Object]
  def assign(name, value)
    if @values.key?(name.lexeme)
      return @values[name.lexeme] = value
    end

    return @enclosing.assign(name, value) unless @enclosing.nil?

    raise RuLoxRuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end

  # @param distance [Integer]
  # @param name [Token]
  # @param value [Object]
  def assign_at(distance, name, value)
    _ancestor(distance).values[name.lexeme] = value
  end

  private

  # @param distance [Integer]
  def _ancestor(distance)
    environment = self

    distance.times do
      environment = environment.enclosing
    end

    environment
  end
end