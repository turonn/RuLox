require_relative 'parser/expr'
require_relative 'parser/stmt'

class Resolver
  module FunctionType
    ALL = [
      NONE = "none".freeze,
      FUNCTION = "function".freeze,
      LAMBDA = "lambda".freeze
    ]
  end

  include Expr::Visitor
  include Stmt::Visitor

  # @param interpreter [Interpreter]
  def initialize(interpreter)
    @interpreter = interpreter
    @scopes = []
    @current_function = FunctionType::NONE
  end

  # @param statements [Array<Stmt>]
  def resolve_statements(statements)
    statements.each do |statement|
      _resolve(statement)
    end
  end

  # @param stmt [Stmt::Block]
  def visit_block_stmt(stmt)
    _begin_scope
    resolve_statements(stmt.statements)
    _end_scope
    nil
  end

  # @param stmt [Stmt::Var]
  def visit_var_stmt(stmt)
    _declare(stmt.name)
    _resolve(stmt.initializer) unless stmt.initializer.nil?
    _define(stmt.name)
    nil
  end

  # @param expr [Expr::Variable]
  def visit_variable_expr(expr)
    if !@scopes.empty? && @scopes.last[expr.name.lexeme] === false
      RuLox.resolver_error(expr.name, "Can't read local variable in its own initializer.")
    end

    _resolve_local(expr, expr.name)
    nil
  end

  # @param expr [Expr::Lambda]
  def visit_lambda_expr(expr)
    _resolve_function(expr, FunctionType::LAMBDA)
    nil
  end

  # @param exp [Expr::Assign]
  def visit_assign_expr(expr)
    _resolve(expr.value)
    _resolve_local(expr, expr.name)
    nil
  end

  # @param stmt [Stmt:Function]
  def visit_function_stmt(stmt)
    _declare(stmt.name)
    _define(stmt.name)
    _resolve_function(stmt, FunctionType::FUNCTION)
    nil
  end

  # @param stmt [Stmt::Expression]
  def visit_expression_stmt(stmt)
    _resolve(stmt.expression)
    nil
  end

  # @param stmt [Stmt::If]
  def visit_if_stmt(stmt)
    _resolve(stmt.condition)
    _resolve(stmt.then_branch)
    _resolve(stmt.else_branch) unless stmt.else_branch.nil?
    nil
  end

  # @param stmt [Stmt::Print]
  def visit_print_stmt(stmt)
    _resolve(stmt.expression)
    nil
  end

  # @param stmt [Stmt::Return]
  def visit_return_stmt(stmt)
    if @current_function == FunctionType::NONE
      RuLox.resolver_error(stmt.keyword, "Can't return from top-level code.")
    end
    _resolve(stmt.value) unless stmt.value.nil?
    nil
  end

  # @param stmt [Stmt::While]
  def visit_while_stmt(stmt)
    _resolve(stmt.condition)
    _resolve(stmt.body)
    nil
  end

  # @param expr [Expr::Binary]
  def visit_binary_expr(expr)
    _resolve(expr.left)
    _resolve(expr.right)
    nil
  end

  # @param expr [Expr::Call]
  def visit_call_expr(expr)
    expr.arguments.each do |argument|
      _resolve(argument)
    end

    puts "...."
    puts expr.callee.inspect
    puts "xxxx"
    if expr.callee.is_a?(Lambda)
      puts "i'm here"
      visit_lambda_expr(expr.callee)
    else
      _resolve(expr.callee)
    end

    nil
  end

  # @param expr [Expr::Grouping]
  def visit_grouping_expr(expr)
    _resolve(expr.expression)
    nil
  end

  # @param expr [Expr::Literal]
  def visit_literal_expr(expr)
    nil
  end

  # @param expr [Expr::Logical]
  def visit_logical_expr(expr)
    _resolve(expr.left)
    _resolve(expr.right)
    nil
  end

  # @param expr [Expr::Unary]
  def visit_unary_expr(expr)
    _resolve(expr.right)
    nil
  end

  private

  # @param expr [Expr]
  # @param name [Token]
  def _resolve_local(expr, name)
    @scopes.reverse.each_with_index do |scope, index|
      if scope.has_key?(name.lexeme)
        @interpreter.resolve(expr, index)
        return
      end
    end
  end

  def _begin_scope
    @scopes << {}
  end

  def _end_scope
    @scopes.pop
  end

  # @param function Either[Stmt::Function, Expr::Lambda]
  # @param type [FunctionType]
  def _resolve_function(function, type)
    enclosing_function = @current_function
    @current_function = type
    _begin_scope
    function.params.each do |param|
      _declare(param)
      _define(param)
    end
    _resolve(function.body)
    _end_scope
    @current_function = enclosing_function
  end

  # @param expr_or_stmt Either[Stmt, Expr]
  def _resolve(expr_or_stmt)
    expr_or_stmt.accept(self)
  end

  # @param name [Token]
  def _declare(name)
    return if @scopes.empty?

    scope = @scopes.last
    if scope.has_key?(name.lexeme)
      RuLox.resolver_error(name, "Already a variable with this name in this scope.")
    end

    scope[name.lexeme] = false
  end

  # @param name [Token]
  def _define(name)
    return if @scopes.empty?

    @scopes.last[name.lexeme] = true
  end
end
