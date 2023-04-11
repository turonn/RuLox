class Stmt
  NotImplementedError = Class.new(StandardError)
  def accept(visitor)
    raise NotImplementedError
  end

  module Visitor
    def visit_block_stmt(expr); end
    def visit_expression_stmt(expr); end
    def visit_function_stmt(expr); end
    def visit_if_stmt(expr); end
    def visit_var_stmt(expr); end
    def visit_print_stmt(expr); end
    def visit_while_stmt(expr); end
  end

  class Block
    attr_reader :statements

    # @param statements [Array<Stmt>]
    def initialize(statements)
      @statements = statements
    end

    # @param visitor [Stmt::Visitor]
    def accept(visitor)
      visitor.visit_block_stmt(self)
    end
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

  class Function
    attr_reader :name, :params, :body

    # @param name [Token]
    # @param params [Array<Token>]
    # @param body [Stmt]
    def initialize(name, params, body)
      @name = name
      @params = params
      @body = body
    end

    # @param visitor [Stmt::Visitor]
    def accept(visitor)
      visitor.visit_function_stmt(self)
    end
  end

  class If
    attr_reader :condition, :then_branch, :else_branch

    # @param condition [Expr]
    # @param then_branch [Stmt]
    # @param else_branch [Stmt]
    def initialize(condition, then_branch, else_branch)
      @condition = condition
      @then_branch = then_branch
      @else_branch = else_branch
    end

    # @param visitor [Stmt::Visitor]
    def accept(visitor)
      visitor.visit_if_stmt(self)
    end
  end

  class Var
    attr_reader :name, :initializer

    # @param name [Token]
    # @param initializer [Expr]
    def initialize(name, initializer)
      @name = name
      @initializer = initializer
    end

    # @param visitor [Stmt::Visitor]
    def accept(visitor)
      visitor.visit_var_stmt(self)
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

  class While
    attr_reader :condition, :body

    # @param condition [Expr]
    # @param body [Stmt]
    def initialize(condition, body)
      @condition = condition
      @body = body
    end

    # @param visitor [Stmt::Visitor]
    def accept(visitor)
      visitor.visit_while_stmt(self)
    end
  end
end
