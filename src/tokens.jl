export TokenType, Token, to_string

@enum TokenType begin
    # single characters 
    LEFT_PAREN
    RIGHT_PAREN
    LEFT_BRACE
    RIGHT_BRACE
    COMMA
    DOT 
    MINUS 
    PLUS 
    SEMICOLON 
    SLASH 
    STAR 

    # one of two character tokens
    BANG 
    BANG_EQUAL 
    EQUAL 
    EQUAL_EQUAL
    GREATER 
    GREATER_EQUAL 
    LESS
    LESS_EQUAL 

    # literals 
    IDENTIFIER
    STRING
    NUMBER 

    # keywords 
    AND 
    CLASS 
    ELSE 
    FALSE 
    FUN 
    FOR 
    IF 
    NIL 
    OR 
    PRINT
    RETURN 
    SUPER 
    THIS 
    TRUE 
    VAR
    WHILE
    EOF
end

struct Token
    type::TokenType 
    lexeme::String 
    line::Int
    # a literal julia representation of the value: we can restrict this later
    literal 
end

function string(token::Token)
    return token.type * " " * token.lexeme * " " * token.literal
end