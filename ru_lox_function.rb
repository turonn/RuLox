require './errors/return'
class RuLoxFunction < RuLoxCallable

  # @param declaration [Stmt::Function]
  # @param closure [Environment]
  def initialize(declaration, closure)
    @declaration = declaration
    @closure = closure
  end
  def arity
    @declaration.params.size
  end

  def to_s
    "<fn #{@declaration.name.lexeme} >"
  end

  def call(interpreter, arguments)
    @environment = Environment.new(@closure)

    @declaration.params.each_with_index do |parameter, index|
      @environment.define(parameter.lexeme, arguments[index])
    end

    begin
      interpreter.execute_block(@declaration.body, @environment)
    rescue => e
      e.value
    end
  end
end