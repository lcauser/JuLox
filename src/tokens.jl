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

    # one or two character tokens
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

LiteralUnion = Union{Float64, String, Char, Nothing}

struct Token
    type::TokenType 
    lexeme::String 
    line::Int
    literal::LiteralUnion
end

function string(token::Token)
    return token.type * " " * token.lexeme * " " * token.literal
end

keywords = Dict(
    "and" => AND,
    "class" => CLASS,
    "else" => ELSE,
    "false" => FALSE,
    "for" => FOR,
    "fun" => FUN,
    "if" => IF,
    "nul" => NIL,
    "or" => OR,
    "print" => PRINT,
    "return" => RETURN,
    "super" => SUPER,
    "this" => THIS,
    "true" => TRUE,
    "var" => VAR,
    "while" => WHILE
)