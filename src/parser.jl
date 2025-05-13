export Parser 
"""
    Parser(tokens::Vector{Token}, [current::Int])

A structure used to contain parsed information. It will take a list of tokens and walk 
through them, interpretting the meaning.
"""
mutable struct Parser 
    tokens::Vector{Token}
    current::Int

    function Parser(tokens::Vector{Token})
        return new(tokens, 1)
    end
end


### Recursive AST generation
"""
    parse(parser::Parser)

Recurses throw the tokens to determine an expression.
"""
function Base.parse(parser::Parser)
    try
        return expression!(parser)
    catch err
        if err isa ParseException
            return nothing 
        else
            throw(err)
        end
    end
end

function expression!(parser::Parser)
    return equality!(parser)
end

function equality!(parser::Parser)
    expr = comparison!(parser)
    while match!(parser, BANG_EQUAL, EQUAL_EQUAL)
        operator = previous(parser)
        right = comparsion!(parser)
        expr = Binary(expr, operator, right)
    end
    return expr
end

function comparison!(parser::Parser)
    expr = term!(parser)
    while match!(parser, GREATER, GREATER_EQUAL, LESS, LESS_EQUAL)
        operator = previous(parser)
        right = term!(parser)
        expr = Binary(expr, operator, right)
    end
    return expr
end

function term!(parser::Parser)
    expr = factor!(parser)

    while match!(parser, MINUS, PLUS)
        operator = previous(parser)
        right = factor!(parser)
        expr = Binary(expr, operator, right)
    end

    return expr
end

function factor!(parser::Parser)
    expr = unary!(parser)
    while match!(parser, SLASH, STAR)
        operator = previous(parser)
        right = unary!(parser)
        expr = Binary(expr, operator, right)
    end
    return expr
end

function unary!(parser::Parser)
    if match!(parser, BANG, MINUS)
        operator = previous(parser)
        right = unary!(parser)
        return Unary(operator, right)
    end
    return primary!(parser)
end

function primary!(parser::Parser)
    match!(parser, FALSE) && return Literal(false)
    match!(parser, TRUE) && return Literal(true)
    match!(parser, NIL) && return Literal(nothing)
    match!(parser, NUMBER, STRING) && return Literal(previous(parser).literal)
    if match!(parser, LEFT_PAREN)
        expr = expression!(parser)
        consume!(parser, RIGHT_PAREN, "Expect ')' after expression.")
        return Grouping(expr)
    end

    throw(error(peek(parser), "Expect expression."))
end


### Walking the tokens
"""
    match!(parser::Parser, types::TokenType...)

Checks if the type of the current token matches some given types, and advances onto the 
next one.
"""
function match!(parser::Parser, types::TokenType...)
    for type in types
        if check(parser, type)
            advance!(parser)
            return true
        end
    end
    return false
end

"""
    check(parser::Parser, type::TokenType)

Checks the current token has the given type.
"""
function check(parser::Parser, type::TokenType)
    is_at_end(parser) && return false
    return peek(parser).type == type 
end

function advance!(parser::Parser)
    if !is_at_end(parser)
        parser.current += 1
    end
    return previous(parser)
end

function is_at_end(parser::Parser)
    return peek(parser).type == EOF
end

function peek(parser::Parser)
    return parser.tokens[parser.current]
end

function previous(parser::Parser)
    return parser.tokens[parser.current-1]
end

### Error handling 

struct ParseException <: Exception
    message::String
end

Base.showerror(io::IO, err::ParseException) = print(io, err.message)

function consume!(parser::Parser, type::TokenType, message::String)
    check(parser, type) && return advance!(parser)

    throw(error(peek(parser), message))
end

function error(token::Token, message::String)
    if token.type == EOF
        report(token.line, " at end", message)
    else
        report(token.line, " at '" * str(token.lexeme) * "'", message)
    end
end

function synchronize!(parser::Parser)
    advance!(parser)
    while !is_at_end(parser)
        previous(parser).type == SEMICOLON && return 
        if peek(parser).type in (CLASS, FUN, VAR, FOR, IF, WHILE, PRINT, RETURN)
            return
        end
    end 
    advance!(parser)
end