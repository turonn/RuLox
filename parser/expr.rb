class Expr
  NotImplementedError = Class.new(StandardError)
  def accept(visitor)
    raise NotImplementedError
  end
end

class Visitor
  def visit_binary_expr(expr); end
  def visit_grouping_expr(expr); end
  def visit_literal_expr(expr); end
  def visit_unary_expr(expr); end
end

class Binary < Expr
  attr_reader :left, :operator, :right

  # @param left [Expr]
  # @param operator[Token]
  # @param right [Expr]
  def initialize(left, operator, right)
    @left = left
    @operator = operator
    @right = right
  end

  # @param visitor [Visitor]
  def accept(visitor)
    visitor.visit_binary_expr(self)
  end
end

class Grouping < Expr
  attr_reader :expression

  # @param expression [Expr]
  def initialize(expression)
    @expression = expression
  end

  # @param visitor [Visitor]
  def accept(visitor)
    visitor.visit_grouping_expr(self)
  end
end

class Literal < Expr
  attr_reader :value

  # @param value [Object]
  def initialize(value)
    @value = value
  end

  # @param visitor [Visitor]
  def accept(visitor)
    visitor.visit_literal_expr(self)
  end
end

class Unary < Expr
  attr_reader :operator, :right

  # @param operator[Token]
  # @param right [Expr]
  def initialize(operator, right)
    @operator = operator
    @right = right
  end

  # @param visitor [Visitor]
  def accept(visitor)
    visitor.visit_unary_expr(self)
  end
end