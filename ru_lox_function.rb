require './errors/return'
class RuLoxFunction < RuLoxCallable

  # @param declaration Either[Stmt::Function, Lambda]
  # @param closure [Environment]
  def initialize(declaration, closure)
    @declaration = declaration
    @closure = closure
  end
  def arity
    @declaration.params.size
  end

  def to_s
    return "<fn #{@declaration.name.lexeme} >" if @declaration.name&.lexeme.present?
    "<anonymous fn>"
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