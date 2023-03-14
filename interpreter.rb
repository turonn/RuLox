require_relative './environment'
require_relative './parser/expr'
require_relative './parser/stmt'
require_relative './errors/ru_lox_runtime_error'

class Interpreter
  include Expr::Visitor
  include Stmt::Visitor

  def initialize
    @environment = Environment.new
  end

  # @param statements [Array<Stmt>]
  def interpret(statements)
    begin
      statements.each { |statement| _execute(statement) }
    rescue RuLoxRuntimeError => error
      RuLox.runtime_error(error)
    end
  end

  def visit_literal_expr(expr)
    expr.value
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

  # @param expr [Expr]
  def visit_variable_expr(expr)
    @environment.get(expr.name)
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
  def visit_expression_stmt(stmt)
    _evaluate(stmt.expression)
  end

  # @param stmt [Stmt]
  def visit_print_stmt(stmt)
    value = _evaluate(stmt.expression)
    puts _stringify(value)
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
end