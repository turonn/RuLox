require_relative './environment'
require_relative './parser/expr'
require_relative './parser/stmt'
require_relative './errors/ru_lox_runtime_error'
require_relative './errors/return'
require_relative './ru_lox_callable'
require_relative './ru_lox_function'

class Interpreter
  include Expr::Visitor
  include Stmt::Visitor

  attr_reader :globals
  def initialize
    @globals = Environment.new
    @environment = @globals

    _define_native_functions
  end

  # @param statements [Array<Stmt>]
  def interpret(statements)
    begin
      statements.each { |statement| _execute(statement) }
    rescue RuLoxRuntimeError => error
      RuLox.runtime_error(error)
    end
  end

  def interpret_expression(expression)
    begin
      value = _evaluate(expression)
      # binding.pry
      puts _stringify(value)
    rescue RuLoxRuntimeError => error
      RuLox.runtime_error(error)
    end
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_logical_expr(expr)
    left = _evaluate(expr.left)

    if expr.operator == TokenType::OR
      return left if _is_truthy?(left)
    else # the AND case
      return left unless _is_truthy?(left)
    end

    _evaluate(expr.right)
  end
  
  def visit_grouping_expr(expr)
    _evaluate(expr.expression)
  end

  def visit_unary_expr(expr)
    right = _evaluate(expr.right)

    case expr.operator.type
    when TokenType::BANG then !_is_truthy?(right)
    when TokenType::MINUS
      _check_number_operands(expr.operator, [right])
      right * -1
    else
      #some error
    end
  end

  def visit_ternary_expr(expr)
    if _evaluate(expr.condition)
      _evaluate(expr.truth_case)
    else
      _evaluate(expr.false_case)
    end
  end
  
  def visit_binary_expr(expr)
    left = _evaluate(expr.left)
    right = _evaluate(expr.right)

    case expr.operator.type
    # the comparisons
    when TokenType::GREATER
      _check_number_operands(expr.operator, [left, right])
      left > right
    when TokenType::GREATER_EQUAL
      _check_number_operands(expr.operator, [left, right])
      left >= right
    when TokenType::LESS
      _check_number_operands(expr.operator, [left, right])
      left < right
    when TokenType::LESS_EQUAL
      _check_number_operands(expr.operator, [left, right])
      left <= right
    when TokenType::BANG_EQUAL then !_is_equal?(left, right)
    when TokenType::EQUAL_EQUAL then _is_equal?(left, right)

    # the math operators
    when TokenType::MINUS
      _check_number_operands(expr.operator, [left, right])
      left - right
    when TokenType::PLUS
      if left.is_a?(Numeric) && right.is_a?(Numeric)
        return left + right
      end

      if left.is_a?(String) && right.is_a?(String)
        return left.concat(right)
      end

      raise RuLoxRuntimeError.new(expr.operator, "Operands must be two numbers or two strings.")
    when TokenType::SLASH
      _check_number_operands(expr.operator, [left, right])
      left.to_f / right.to_f
    when TokenType::STAR
      _check_number_operands(expr.operator, [left, right])
      left * right
    when TokenType::CARROT
      _check_number_operands(expr.operator, [left, right])
      left ** right
    
    # error state
    else
      raise RuLoxRuntimeError.new(expr.operator, "Unhandled binary operator within interpreter.")
    end
  end

  # @param expr [Call]
  def visit_call_expr(expr)
    callee = _evaluate(expr.callee)
    raise RuLoxRuntimeError.new(expr.paren, "Can only call functions and classes.") unless callee.is_a? RuLoxCallable

    arguments = expr.arguments.map { |argument| _evaluate(argument) }

    unless callee.arity == arguments.size
      relevant_plural = callee.arity == 1 ? "argument" : "arguments"
      raise RuLoxRuntimeError.new(expr.paren, "Expected #{callee.arity} #{relevant_plural} but got #{arguments.size}.")
    end

    callee.call(self, arguments)
  end

  # @param expr [Expr]
  def visit_assign_expr(expr)
    value = _evaluate(expr.value)
    @environment.assign(expr.name, value)

    value
  end

  # @param expr [Expr]
  def visit_variable_expr(expr)
    @environment.get(expr.name)
  end

  # @param expr [Lambda]
  def visit_lambda_expr(expr)
    RuLoxFunction.new(expr, @environment)
  end

  # @param stmt [Stmt]
  def visit_var_stmt(stmt)
    value = if stmt.initializer.nil?
              nil
            else
              _evaluate(stmt.initializer)
            end

    @environment.define(stmt.name.lexeme, value)
    nil
  end

  # @param stmt [Stmt]
  def visit_while_stmt(stmt)
    while _is_truthy?(_evaluate(stmt.condition))
      _execute(stmt.body)
    end

    nil
  end

  # @param block [Stmt]
  def visit_block_stmt(block)
    execute_block(block, Environment.new(@environment))
  end

  # @param stmt [Stmt]
  def visit_expression_stmt(stmt)
    _evaluate(stmt.expression)
  end

  # @param stmt [Stmt::Function]
  def visit_function_stmt(stmt)
    function = RuLoxFunction.new(stmt, @environment)
    @environment.define(stmt.name.lexeme, function) unless stmt.name.nil?
  end

  def visit_if_stmt(stmt)
    if _is_truthy?(_evaluate(stmt.condition))
      _execute(stmt.then_branch)
    elsif !stmt.else_branch.nil?
      _execute(stmt.else_branch)
    end
  end

  # @param stmt [Stmt]
  def visit_print_stmt(stmt)
    value = _evaluate(stmt.expression)
    puts _stringify(value)
  end

  # @param stmt [Stmt::Return]
  def visit_return_stmt(stmt)
    value = if stmt.value.nil?
              nil
            else
              _evaluate(stmt.value)
            end

    raise Return.new(stmt.keyword, value)
  end

  def execute_block(block, environment)
    previous_environment = @environment

    begin
      @environment = environment
      block.statements.each { |stmt| _execute(stmt) }
    rescue => e
      if e.is_a?(Return)
        @environment = previous_environment
        raise e
      end
      puts e.message
    end

    @environment = previous_environment
    nil
  end

  private

  # @param statement [Stmt]
  def _execute(statement)
    statement.accept(self)
  end

  # @param expr [Expression]
  def _evaluate(expr)
    expr.accept(self)
  end

  # only `false` and `nil` are "falsey"
  def _is_truthy?(object)
    return false if object.nil?
    return object if [true, false].include?(object)

    true
  end

  def _is_equal?(a, b)
    if a.nil?
      return true if b.nil?
      return false
    end

    a == b
  end

  # @param operator [TokenType]
  # @param operand [Array<Object>]
  def _check_number_operands(operator, operands)
    return if operands.all? { |o| o.is_a?(Numeric) }
    message = operands.length > 1 ? 'Operands must be numbers.' : 'Operand must be a number.'

    raise RuLoxRuntimeError.new(operator, message)
  end

  def _stringify(object)
    return "nil" if object.nil?

    text = object.to_s

    # all numbers are floats in RuLox.
    if object.is_a?(Numeric) && text.end_with?(".0")
      return text[0...-2]
    end

    text
  end

  def _define_native_functions
    _define_clock
  end

  def _define_clock
    clock = RuLoxCallable.new
    clock.instance_eval do
      def arity
        0
      end

      def call(_interpreter, _arguments)
        Time.now.to_f
      end

      def to_s
        '<native fn>'
      end
    end

    @globals.define('clock', clock)
  end
end