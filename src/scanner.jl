"""
    Scanner(source::String)

Scans a string to produce a sequence of syntax tokens.
"""
mutable struct Scanner
    source::String 
    tokens::Vector{Token}
    start::Int
    current::Int
    line::Int
    errored::Bool

    function Scanner(source::String)
        scanner = new(source, Token[], 1, 1, 1, false)
        scan_tokens!(scanner)
        return scanner 
    end
end

"""
    is_at_end(scanner::Scanner)

Determines if the scanner is at the end of the source.
"""
function is_at_end(scanner::Scanner)
    return scanner.current > length(scanner.source)
end

"""
    scan_tokens!(scanner::Scanner)

Scans through the source, iteratively determining all tokens.
"""
function scan_tokens!(scanner::Scanner)
    while !is_at_end(scanner)
        scanner.start = scanner.current 
        scan_token!(scanner)
    end
    push!(scanner.tokens, Token(EOF, "", scanner.line, nothing))
end

"""
    scan_token!(scanner::Scanner)

Scans the next token in the source.
"""
function scan_token!(scanner::Scanner)
    c = advance!(scanner)
    if c == '('
        add_token!(scanner, LEFT_PAREN)
    elseif c == ')'
        add_token!(scanner, RIGHT_PAREN)
    elseif c == '{'
        add_token!(scanner, LEFT_BRACE)
    elseif c == '}'
        add_token!(scanner, RIGHT_BRACE)
    elseif c == ','
        add_token!(scanner, COMMA)
    elseif c == '.'
        add_token!(scanner, DOT)
    elseif c == '-'
        add_token!(scanner, MINUS)
    elseif c == '+'
        add_token!(scanner, PLUS)
    elseif c == ';'
        add_token!(scanner, SEMICOLON)
    elseif c == '*'
        add_token!(scanner, STAR)
    elseif c == '!'
        add_token!(scanner, match(scanner, '=') ? BANG_EQUAL : BANG)
    elseif c == '='
        add_token!(scanner, match(scanner, '=') ? EQUAL_EQUAL : EQUAL)
    elseif c == '<'
        add_token!(scanner, match(scanner, '=') ? LESS_EQUAL : LESS)
    elseif c == '>'
        add_token!(scanner, match(scanner, '=') ? GREATER_EQUAL : GREATER)
    elseif c == '/'
        if match(scanner, '/')
            while peek(scanner) != '\n' && !is_at_end(scanner)
                advance!(scanner)
            end
        else
            add_token!(scanner, SLASH)
        end
    elseif c == ' ' || c == '\r' || c == '\t'
    elseif c == '\n'
        scanner.line += 1
    elseif c == '"'
        string!(scanner)
    elseif isdigit(c)
        number!(scanner)
    elseif isletter(c) || c == '_'
        identifier!(scanner)
    else
        error(scanner, "Unexpected character " * c)
    end
end

"""
    advance!(scanner::Scanner)

Advances to the next character in the source for inspection.
"""
function advance!(scanner::Scanner)
    val = scanner.source[scanner.current]
    scanner.current += 1
    return val 
end

"""
    add_token!(scanner::Scanner, type::TokenType, [literal])

Adds a token to the scanner, storing the source string that produced the token, and a
literal Julia implementation of the value if necessary.
"""
function add_token!(scanner::Scanner, type::TokenType, literal)
    text = scanner.source[scanner.start:scanner.current-1]
    push!(scanner.tokens, Token(type, text, scanner.line, literal))
end

function add_token!(scanner::Scanner, type::TokenType)
    add_token!(scanner, type, nothing)
end

"""
    error(scanner::Scanner, message::String)

If an error is encounted in scanning, this is returned.
"""
function error(scanner::Scanner, message::String)
    scanner.errored = true 
    error(scanner.line, message)
end

"""
    match(scanner::Scanner, expected::Char)

Checks the next character and matches it against a given character.
"""
function match(scanner::Scanner, expected::Char)
    is_at_end(scanner) && return false
    scanner.source[scanner.current] != expected && return false 
    scanner.current += 1 
    return true
end

"""
    peek(scanner::Scanner, [offset::Int=1])

Looks at the next character without advancing. Use offset to determine how far to look 
ahead.
"""
function peek(scanner::Scanner, offset::Int=1)
    scanner.current + offset - 1 > length(scanner.source) && return '\0'
    return scanner.source[scanner.current + offset - 1]
end

"""
    string!(scanner::Scanner)

Iteratively scans the next characters in the source to determine a string.
"""
function string!(scanner::Scanner)
    while peek(scanner) != '"' && !is_at_end(scanner)
        if peek(scanner) == "\n"
            scanner.line += 1
        end
        advance!(scanner)
    end
    is_at_end(scanner) && error(scanner, "Unterminated string.")
    advance!(scanner)
    value = scanner.source[scanner.start+1:scanner.current-2]
    add_token!(scanner, STRING, value)
end

"""
    number!(scanner::Scanner)

Iteratively scans the next characters in the source to determine a number, either a float 
or an integer.
"""
function number!(scanner::Scanner)
    while isdigit(peek(scanner))
        advance!(scanner)
    end
    if peek(scanner) == '.' && isdigit(peek(scanner, 2))
        advance!(scanner) # consume the "."
        while isdigit(peek(scanner))
            advance!(scanner)
        end
    end
    add_token!(
        scanner, NUMBER, parse(Float64, scanner.source[scanner.start:scanner.current-1])
    )
end

"""
    identifier!(scanner::Scanner)

Adds an identifier token to the scanner, which might be predined syntax such as for, if,
etc, or refer to a variable or function declaration.
"""
function identifier!(scanner::Scanner)
    while isalphanumeric(peek(scanner))
        advance!(scanner)
    end

    text = scanner.source[scanner.start:scanner.current-1]
    type = get(keywords, text, IDENTIFIER)

    add_token!(scanner, type)
end

"""
    isalphanumeric(c::Char)

Helper function to determine if a character is alphanumeric.
"""
function isalphanumeric(c::Char)
    return isletter(c) || isdigit(c) || c == '_'
end