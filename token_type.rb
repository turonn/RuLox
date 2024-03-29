module TokenType
  ALL = [
    # single character
    LEFT_PAREN = 'left_paren',
    RIGHT_PAREN = 'right_paren',
    LEFT_BRACE = 'left_brace',
    RIGHT_BRACE = 'right_brace',
    CARROT = 'carrot',
    COLON = 'colon',
    COMMA = 'comma',
    DOT = 'dot',
    MINUS = 'minus',
    PLUS = 'plus',
    QUESTION = 'question',
    SEMICOLON = 'semicolon',
    SLASH = 'slash',
    STAR = 'star',

    # one or two characters
    BANG = 'bang',
    BANG_EQUAL = 'bang_equal',
    EQUAL = 'equal',
    EQUAL_EQUAL = 'equal_equal',
    GREATER = 'greater',
    GREATER_EQUAL = 'greater_equal',
    LESS = 'less',
    LESS_EQUAL = 'less_equal',

    # literals
    IDENTIFIER = 'identifier',
    STRING = 'string',
    NUMBER = 'number',

    # keywords
    AND = 'and',
    BREAK = 'break',
    CLASS = 'class',
    ELSE = 'else',
    FALSE = 'false',
    FUN = 'fun',
    FOR = 'for',
    IF = 'if',
    NIL = 'nil',
    OR = 'or',
    PRINT = 'print',
    RETURN = 'return',
    SUPER = 'super',
    THIS = 'this',
    TRUE = 'true',
    VAR = 'var',
    WHILE = 'while',

    EOF = 'eof'
  ].freeze

  StartOfStatementTypes = [
    CLASS, FUN, FOR, IF, PRINT, RETURN, VAR, WHILE
  ]

  # these are the tokens that can preceed a negative number
  PreceedingNegativeTokens = [
    EQUAL,

    # comparative
    BANG_EQUAL, EQUAL_EQUAL, GREATER, GREATER_EQUAL, LESS, LESS_EQUAL,

    # operators
    CARROT, MINUS, PLUS, SLASH, STAR,

    # openings
    LEFT_PAREN, LEFT_BRACE, RIGHT_BRACE, COMMA
  ]

  Keywords = [
    AND, BREAK, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR, PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE
  ]
end
