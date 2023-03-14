class Stmt
  NotImplementedError = Class.new(StandardError)
  def accept(visitor)
    raise NotImplementedError
  end

  module Visitor
    def visit_expression_stmt(expr); end
    def visit_var_stmt(expr); end
    def visit_print_stmt(expr); end
  end
end

class Expression < Stmt
  attr_reader :expression

  # @param expression [Expr]
  def initialize(expression)
    @expression = expression
  end

  # @param visitor [Stmt::Visitor]
  def accept(visitor)
    visitor.visit_expression_stmt(self)
  end
end

class Var < Stmt
  attr_reader :name, :initializer

  # @param name [Token]
  # @param initializer [Expr]
  def initialize(name, initializer)
    @name = name
    @initializer = initializer
  end

  # @param visitor [Stmt::Visitor]
  def accept(visitor)
    visitor.visit_expression_stmt(self)
  end
end

class Print < Stmt
  attr_reader :expression

  # @param expression [Expr]
  def initialize(expression)
    @expression = expression
  end

  # @param visitor [Stmt::Visitor]
  def accept(visitor)
    visitor.visit_print_stmt(self)
  end
end
