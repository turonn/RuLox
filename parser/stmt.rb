class Stmt
  NotImplementedError = Class.new(StandardError)
  def accept(visitor)
    raise NotImplementedError
  end

  module Visitor
    def visit_expression_stmt(expr); end
    def visit_print_stmt(expr); end
  end

  class Expression
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

  class Print
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
end