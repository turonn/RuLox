require_relative './expr'
class AstPrinter < Visitor
  # @param expression [Expr]
  # @return [String]
  def print(expression)
    expression.accept(self)
  end

  def visit_binary_expr(expr)
    _parenthesize(expr.operator.lexeme, [expr.left, expr.right])
  end

  def visit_grouping_expr(expr)
    _parenthesize("group", [expr.expression])
  end

  def visit_literal_expr(expr)
    return "nil" if expr.value.nil?
    expr.value.to_s
  end

  def visit_unary_expr(expr)
    _parenthesize(expr.operator.lexeme, [expr.right])
  end

  private

  # @param name [String]
  # @param expressions[Array[Expr]]
  # @return [String]
  def _parenthesize(name, expressions)
    pp "(#{name} #{expressions.map { |e| e.accept(self).to_s }.join(' ')})"
  end
end