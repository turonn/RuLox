require 'pry'
class RuLoxFunction < RuLoxCallable

  # @param declaration [Stmt::Function] the parameters expected
  def initialize(declaration)
    @declaration = declaration
  end
  def arity
    @declaration.params.size
  end

  def to_s
    "<fn #{@declaration.name.lexeme} >"
  end

  def call(interpreter, arguments)
    @environment = Environment.new(interpreter.globals)

    @declaration.params.each_with_index do |parameter, index|
      @environment.define(parameter.lexeme, arguments[index])
    end

    interpreter.execute_block(@declaration.body, @environment)
  end
end