mutable struct Scanner
    source::String 
    tokens::Vector{Token}
    start::Int
    current::Int
    line::Int
    errored::Bool

    function Scanner(source::String)
        scanner = new(source, Token[], 1, 1, 1, false)
        return scanner 
    end
end

function is_at_end(scanner::Scanner)
    return scanner.current >= length(scanner.source)
end

function scan_tokens!(scanner::Scanner)
    while !is_at_end(scanner)
        scanner.start = scanner.current 
        scan_token!(scanner)
    end
    append!(scanner.tokens, Token(EOF, "", nothing, scanner.line))
end

function scan_token!(scanner::Scanner)
    c = advance!(scanner)
    if c == "("
        token = LEFT_PAREN
    elseif c == ")"
        token = RIGHT_PAREN
    elseif c == "{"
        token = LEFT_BRACE
    elseif c == "}"
        token = RIGHT_BRACE
    elseif c == ","
        token = COMMA
    elseif c == "."
        token = DOT
    elseif c == "-"
        token = MINUS
    elseif c == "+"
        token = PLUS
    elseif c == ";"
        token = SEMICOLON
    elseif c == "*"
        token = STAR
    elseif c == "!"

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
    text = scanner.source[scanner.start:scanner.current]
    append!(scanner.tokens, Token(type, text, literal, scanner.line))
end

function add_token!(scanner::Scanner, type::TokenType)
    add_token!(scanner, type, nothing)
end

function error(scanner::Scanner, message::str)
    scanner.errored = true 
    error(scanner.line, message)
end

function match(scanner::Scanner, expected::str)
    is_at_end(scanner) && return false
    scanner.source[scanner.current] != expected && return false 
    scanner.current += 1 
    return true
end