require_relative '../token_type'
require_relative 'expr'

class Parser
  ParseError = Class.new(RuntimeError)

  # @param tokens [Array[Token]]
  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    begin
    _expression
    rescue ParseError => e
      nil
    end
  end

  private

  def _expression
    _equality
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
    expr = _exponant

    while _match([TokenType::SLASH, TokenType::STAR])
      operator = _previous
      right = _exponant
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def _exponant
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

    _primary
  end

  def _primary
    return Literal.new(false) if _match([TokenType::FALSE])
    return Literal.new(true) if _match([TokenType::TRUE])
    return Literal.new(nil) if _match([TokenType::NIL])

    return Literal.new(_previous.literal) if _match([TokenType::NUMBER, TokenType::STRING])

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
    @tokens[@current]
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