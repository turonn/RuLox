class Expr
  NotImplementedError = Class.new(StandardError)
  def accept(visitor)
    raise NotImplementedError
  end

  module Visitor
    def visit_assign_expr(expr); end
    def visit_ternary_expr(expr); end
    def visit_binary_expr(expr); end
    def visit_grouping_expr(expr); end
    def visit_logical_expr(expr); end
    def visit_literal_expr(expr); end
    def visit_variable_expr(expr); end
    def visit_unary_expr(expr); end
  end
end

class Assign < Expr
  attr_reader :name, :value

  # @param name[Token]
  # @param value [Expr]
  def initialize(name, value)
    @name = name
    @value = value
  end

  # @param visitor [Expr::Visitor]
  def accept(visitor)
    visitor.visit_assign_expr(self)
  end
end

class Ternary < Expr
  attr_reader :condition, :truth_case, :false_case

  # @param condition [Expr]
  # @param truth_case[Token]
  # @param false_case [Expr]
  def initialize(condition, truth_case, false_case)
    @condition = condition
    @truth_case = truth_case
    @false_case = false_case
  end

  # @param visitor [Expr::Visitor]
  def accept(visitor)
    visitor.visit_ternary_expr(self)
  end
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

  # @param visitor [Expr::Visitor]
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

  # @param visitor [Expr::Visitor]
  def accept(visitor)
    visitor.visit_grouping_expr(self)
  end
end

class Logical < Expr
  attr_reader :value

  # @param left [Expr]
  # @param operator [Token]
  # @param right [Expr]
  def initialize(left, operator, right)
    @left = left
    @operator = operator
    @right = right
  end

  # @param visitor [Expr::Visitor]
  def accept(visitor)
    visitor.visit_logical_expr(self)
  end
end

class Literal < Expr
  attr_reader :value

  # @param value [Object]
  def initialize(value)
    @value = value
  end

  # @param visitor [Expr::Visitor]
  def accept(visitor)
    visitor.visit_literal_expr(self)
  end
end

class Variable < Expr
  attr_reader :name

  # @param name [Token]
  def initialize(name)
    @name = name
  end

  # @param visitor [Expr::Visitor]
  def accept(visitor)
    visitor.visit_variable_expr(self)
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

  # @param visitor [Expr::Visitor]
  def accept(visitor)
    visitor.visit_unary_expr(self)
  end
end