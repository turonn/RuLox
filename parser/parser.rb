require_relative '../token_type'
require_relative '../errors/ru_lox_runtime_error'
require_relative '../errors/return'
require_relative 'expr'
require_relative 'stmt'

class Parser
  module FunctionKinds
    ALL = [
      FUNCTION = "function".freeze
    ].freeze
  end

  ParseError = Class.new(RuLoxRuntimeError)

  # @param tokens [Array[Token]]
  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    begin
      statements = []
      while !_is_at_end?
        statements << _declaration
      end
    rescue ParseError => error
      nil
    end

    statements
  end

  def parse_expression
    begin
      _expression
    rescue ParseError => error
      return nil
    end
  end

  private

  def _declaration
    begin
      return _function(FunctionKinds::FUNCTION) if _match([TokenType::FUN])
      return _var_declaration if _match([TokenType::VAR])
      _statement
    rescue ParseError => error
      _syncronize
      return nil
    end
  end

  # @param kind [String]
  def _function(kind)
    name = if _check(TokenType::LEFT_PAREN)
             nil
           else
             _consume(TokenType::IDENTIFIER, "Expect #{kind} name.")
           end
    _consume(TokenType::LEFT_PAREN, "Expect '(' after #{kind} name.")

    parameters = []
    unless _check(TokenType::RIGHT_PAREN)
      parameters << _consume(TokenType::IDENTIFIER, "Expect parameter name.")

      while _match([TokenType::COMMA])
        _error(_peek, "Can't have more than 255 arguments.") if parameters.size >= 255
        parameters << _consume(TokenType::IDENTIFIER, "Expect parameter name.")
      end
    end

    _consume(TokenType::RIGHT_PAREN, "Expect ')' after parameters.")

    _consume(TokenType::LEFT_BRACE, "Expect '{' before #{kind} body.")
    body = _block_statement

    Stmt::Function.new(parameters, body, name)
  end

  def _var_declaration
    name = @tokens[@current]
    _consume(TokenType::IDENTIFIER, "Expect variable name.")

    initializer = if _match([TokenType::EQUAL])
                    _expression
                  else
                    nil
                  end

    _consume(TokenType::SEMICOLON, "Expect ';' after variable declaration.")
    Stmt::Var.new(name, initializer)
  end

  def _statement
    return _for_statement if _match([TokenType::FOR])
    return _if_statement if _match([TokenType::IF])
    return _print_statement if _match([TokenType::PRINT])
    return _return_statement if _match([TokenType::RETURN])
    return _while_statement if _match([TokenType::WHILE])
    return _block_statement if _match([TokenType::LEFT_BRACE])

    _expression_statement
  end

  def _for_statement
    _consume(TokenType::LEFT_PAREN, "Expect '(' after 'for'.")

    # this is a Stmt
    initializer = if _match([TokenType::SEMICOLON])
                    nil
                  elsif _match([TokenType::VAR])
                    _var_declaration
                  else
                    _expression_statement
                  end

    # this is an Expr
    condition = if _check(TokenType::SEMICOLON)
                  Literal.new(true)
                else
                  _expression
                end
    _consume(TokenType::SEMICOLON, "Expect ';' after loop condition.")

    # this is an Expr
    increment = if _check(TokenType::SEMICOLON)
                  nil
                else
                  _expression
                end
    _consume(TokenType::RIGHT_PAREN, "Expect ')' after for clauses.")

    # this is a Stmt
    body = _statement

    # adds the increment to the end of the body to be repeated with each iteration
    unless increment.nil?
      body = Stmt::Block.new([body, Stmt::Expression.new(increment)])
    end

    # this creates the cycling through the body
    body = Stmt::While.new(condition, body)

    # pop the initializer on the front if there is one
    unless initializer.nil?
      body = Stmt::Block.new([initializer, body])
    end

    body
  end

  def _if_statement
    _consume(TokenType::LEFT_PAREN, "Expect '(' after 'if'.")
    condition = _expression
    _consume(TokenType::RIGHT_PAREN, "Expect ')' after if condition.")

    # if you want to assign variables inside of an if statment, you must do it in a block so it goes all the
    # way back up to the _declaration call. Otherwise, the if statement only looks for _statement and lower
    # and will error out if making a variable declaration.
    then_branch = _statement
    else_branch = _match([TokenType::ELSE]) ? _statement : nil

    Stmt::If.new(condition, then_branch, else_branch)
  end

  def _print_statement
    value = _expression
    _consume(TokenType::SEMICOLON, "Expect ';' after value.")
    Stmt::Print.new(value)
  end

  def _return_statement
    keyword = _previous
    value = if _check(TokenType::SEMICOLON)
              nil
            else
              _expression
            end

    _consume(TokenType::SEMICOLON, "Expect ';' after return value.")
    Stmt::Return.new(keyword, value)
  end

  def _while_statement
    _consume(TokenType::LEFT_PAREN, "Expect '(' after 'while'.")
    condition = _expression
    _consume(TokenType::RIGHT_PAREN, "Expect ')' after while condition.")
    body = _statement

    Stmt::While.new(condition, body)
  end

  def _block_statement
    statements = []

    until _check(TokenType::RIGHT_BRACE) || _is_at_end?
      statements << _declaration
    end

    _advance
    Stmt::Block.new(statements)
  end

  def _expression_statement
    expr = _expression
    _consume(TokenType::SEMICOLON, "Expect ';' after value.")
    Stmt::Expression.new(expr)
  end

  def _expression
    _assignment
  end

  def _assignment
    expr = _or

    if _match([TokenType::EQUAL])
      equals = _previous
      value = _assignment

      if expr.is_a?(Variable)
        name = expr.name
        return Assign.new(name, value)
      end

      _error(equals, "Invalid assignment target.")
    end

    expr
  end

  def _or
    expr = _and

    while _match([TokenType::OR])
      operator = _previous
      right = _and
      expr = Logical.new(expr, operator, right)
    end

    expr
  end

  def _and
    expr = _ternary

    while _match([TokenType::AND])
      operator = _previous
      right = _ternary
      expr = Logical.new(expr, operator, right)
    end

    expr
  end

  def _ternary
    expr = _equality

    if _match([TokenType::QUESTION])
      condition = expr
      truth_case = _equality
      _consume(TokenType::COLON, "Expect ':' between truth and false cases.")
      false_case = _equality

      expr = Ternary.new(condition, truth_case, false_case)
    end

    expr
  end

  def _equality
    expr = _comparison

    while _match([TokenType::EQUAL_EQUAL, TokenType::BANG_EQUAL])
      operator = _previous # we need previous because `_match` advanced
      right = _comparison
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def _comparison
    expr = _term

    while _match([TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL])
      operator = _previous
      right = _term
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def _term
    expr = _factor

    while _match([TokenType::MINUS, TokenType::PLUS])
      operator = _previous
      right = _factor
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def _factor
    expr = _exponent

    while _match([TokenType::SLASH, TokenType::STAR])
      operator = _previous
      right = _exponent
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def _exponent
    expr = _unary

    while _match([TokenType::CARROT])
      operator = _previous
      right = _unary
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def _unary
    if _match([TokenType::BANG, TokenType::MINUS])
      operator = _previous
      right = _unary
      return Unary.new(operator, right)
    end

    _call
  end

  def _call
    expr = _primary

    while true
      if _match([TokenType::LEFT_PAREN])
        expr = _finish_call(expr)
      else
        break
      end
    end

    expr
  end

  def _finish_call(callee)
    arguments = []

    unless _check(TokenType::RIGHT_PAREN)
      arguments << _expression

      while _match([TokenType::COMMA])
        _error(_peek, "Can't have more than 255 arguments.") if arguments.size >= 255
        arguments << _expression
      end
    end

    paren = _consume(TokenType::RIGHT_PAREN, "Expect ')' after arguments.")

    Call.new(callee, paren, arguments)
  end

  def _primary
    return Literal.new(false) if _match([TokenType::FALSE])
    return Literal.new(true) if _match([TokenType::TRUE])
    return Literal.new(nil) if _match([TokenType::NIL])

    return Literal.new(_previous.literal) if _match([TokenType::NUMBER, TokenType::STRING])
    return Variable.new(_previous) if _match([TokenType::IDENTIFIER])

    if _match([TokenType::LEFT_PAREN])
      expr = _expression
      _consume(TokenType::RIGHT_PAREN, "Expect `)` after expression.")
      return Grouping.new(expr)
    end

    raise _error(_peek, "Expect expression.")
  end

  # helper methods

  # @param token_types [Array[TokenType]]
  # @return [Boolean]
  def _match(token_types)
    token_types.each do |token_type|
      if _check(token_type)
        _advance
        return true
      end
    end
    false
  end

  # @param token_type [TokenType]
  # @return [Boolean]
  def _check(token_type)
    return false if _is_at_end?
    _peek.type == token_type
  end

  def _is_at_end?
    _peek.type == TokenType::EOF
  end

  def _peek
    @tokens[@current]
  end

  def _previous
    @tokens[@current - 1]
  end

  def _advance
    @current += 1
    _previous
  end

  def _consume(token_type, message)
    return _advance if _check(token_type)

    raise _error(_peek, message)
  end

  def _error(token, message)
    RuLox.parse_error(token, message)

    ParseError
  end

  # call this to reset after an error
  def _syncronize
    _advance

    while (!_is_at_end?)
      # continue after the end of the last statement (semicolon)
      return if _previous.type == TokenType::SEMICOLON

      # continue if we have started a new statement
      return if TokenType::StartOfStatementTypes.include?(_peek.type)
    end

    _advance
  end
end