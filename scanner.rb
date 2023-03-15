# require_relative 'ru_lox'
require_relative 'token_type'
require_relative 'token'

# @param source [String]
class Scanner
  def initialize(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
  end

  # return [Array[Token]]
  def scan_tokens
    until _is_at_end?
      @start = @current
      _scan_token
    end

    @tokens << Token.new(TokenType::EOF, "", nil, @line)
    @tokens
  end

  private

  def _scan_token
    c = @source[@current]
    case c
      when '(' then _add_token(TokenType::LEFT_PAREN, nil)
      when ')' then _add_token(TokenType::RIGHT_PAREN, nil)
      when '{' then _add_token(TokenType::LEFT_BRACE, nil)
      when '}' then _add_token(TokenType::RIGHT_BRACE, nil)
      when ',' then _add_token(TokenType::COMMA, nil)
      when '.' then _add_token(TokenType::DOT, nil)
      when '+' then _add_token(TokenType::PLUS, nil)
      when ';' then _add_token(TokenType::SEMICOLON, nil)
      when '*' then _add_token(TokenType::STAR, nil)
      when '^' then _add_token(TokenType::CARROT, nil)
      when '?' then _add_token(TokenType::QUESTION, nil)
      when ':' then _add_token(TokenType::COLON, nil)

      # account for possible negative number
      when '-'
        if (_is_at_beginning? || TokenType::PreceedingNegativeTokens.include?(_previous_token&.type)) && _is_digit?(_peek)
          _number
        else
          _add_token(TokenType::MINUS, nil)
        end
      when '!'
        token_type = _next_char_matches?('=') ? TokenType::BANG_EQUAL : TokenType::BANG
        _add_token(token_type, nil)
      when '='
        token_type = _next_char_matches?('=') ? TokenType::EQUAL_EQUAL : TokenType::EQUAL
        _add_token(token_type, nil)
      when '>'
        token_type = _next_char_matches?('=') ? TokenType::GREATER_EQUAL : TokenType::GREATER
        _add_token(token_type, nil)
      when '<'
        token_type = _next_char_matches?('=') ? TokenType::LESS_EQUAL : TokenType::LESS
        _add_token(token_type, nil)
      
      # checking to see if a comment
      when '/'
        if _next_char_matches?('/')
          while !_is_at_end? && _peek != '\n'
            _advance
          end
        else
          _add_token(TokenType::SLASH, nil)
        end

      # ignore white space
      when ' ', "\r", "\t"
      when "\n"then @line += 1

      # literals
      when '"' then _string
      when /[[:digit:]]/ then _number
      when '_', /[[:alpha:]]/ then _identifier
        
      # errors
      else RuLox.error(@line, "Unexpected character. `#{c}`")
    end

    @current += 1
  end

  def _string
    until _peek == '"' || _is_at_end?
      @line += 1 if _peek == '\n'
      _advance
    end

    RuLox.error(@line, "Undetermined string.") if _is_at_end?

    _advance

    # trim the surrounding quotes
    literal = @source[@start + 1..@current - 1]
    _add_token(TokenType::STRING, literal)
  end

  def _number
    until !_is_digit?(_peek) || _is_at_end?
      _advance
    end

    if _peek == '.' && _is_digit?(_peek_next)
      @current += 1
      until !_is_digit?(_peek) || _is_at_end?
        _advance
      end
    end

    literal = @source[@start..@current]
    _add_token(TokenType::NUMBER, literal.to_f)
  end

  def _identifier
    until !_is_alpha_numperic?(_peek) || _is_at_end?
      _advance
    end

    literal = @source[@start..@current]
    type =  if TokenType::Keywords.include?(literal)
              literal
            else
              TokenType::IDENTIFIER
            end

    _add_token(type, literal)
  end

  def _add_token(type, literal)
    lexeme = @source[@start..@current]
    @tokens << Token.new(type, lexeme, literal, @line)
  end

  # return [String] single character
  def _advance
    @current += 1
    @source[@current]
  end

  def _previous_token
    @tokens.last
  end

  def _peek
    return '\0' if @current + 1 >= @source.length
    @source[@current + 1]
  end

  def _peek_next
    return '\0' if @current + 2 >= @source.length
    @source[@current + 2]
  end

  def _is_digit?(c)
    c.match?(/[[:digit:]]/)
  end

  def _is_alpha_or_underscore?(c)
    c.match?(/[[:alpha:]]/) || c == '_'
  end

  def _is_alpha_numperic?(c)
    _is_digit?(c) || _is_alpha_or_underscore?(c)
  end

  def _next_char_matches?(expected)
    return false if _is_at_end?
    return false if @source[@current + 1] != expected

    @current += 1
    true
  end

  def _is_at_beginning?
    @current == 0
  end

  def _is_at_end?
    @current >= @source.length
  end
end