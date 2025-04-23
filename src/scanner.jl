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

function is_at_end(scanner::Scanner)
    return scanner.current > length(scanner.source)
end

function scan_tokens!(scanner::Scanner)
    while !is_at_end(scanner)
        scanner.start = scanner.current 
        scan_token!(scanner)
    end
    push!(scanner.tokens, Token(EOF, "", scanner.line, nothing))
end

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

function advance!(scanner::Scanner)
    val = scanner.source[scanner.current]
    scanner.current += 1
    return val 
end

function add_token!(scanner::Scanner, type::TokenType, literal)
    text = scanner.source[scanner.start:scanner.current-1]
    push!(scanner.tokens, Token(type, text, scanner.line, literal))
end

function add_token!(scanner::Scanner, type::TokenType)
    add_token!(scanner, type, nothing)
end

function error(scanner::Scanner, message::String)
    scanner.errored = true 
    error(scanner.line, message)
end

function match(scanner::Scanner, expected::Char)
    is_at_end(scanner) && return false
    scanner.source[scanner.current] != expected && return false 
    scanner.current += 1 
    return true
end

function peek(scanner::Scanner)
    is_at_end(scanner) && return '\0'
    return scanner.source[scanner.current]
end

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


function number!(scanner::Scanner)
    while isdigit(peek(scanner))
        advance!(scanner)
    end
    if peek(scanner) == '.' && isdigit(peek_next(scanner))
        advance!(scanner) # consume the "."
        while isdigit(peek(scanner))
            advance!(scanner)
        end
    end
    add_token!(
        scanner, NUMBER, parse(Float64, scanner.source[scanner.start:scanner.current-1])
    )
end

function peek_next(scanner::Scanner)
    scanner.current + 1 > length(scanner.source) && return '\0'
    return scanner.source[scanner.current + 1]
end

function identifier!(scanner::Scanner)
    while isalphanumeric(peek(scanner))
        advance!(scanner)
    end

    text = scanner.source[scanner.start:scanner.current-1]
    type = get(keywords, text, IDENTIFIER)

    add_token!(scanner, type)
end

function isalphanumeric(c::Char)
    return isletter(c) || isdigit(c) || c == '_'
end