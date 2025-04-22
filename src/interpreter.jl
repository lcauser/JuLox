export run_julox

"""
    run_julox(args::String...)

Interprets and executes a JuLox program. If given no arguments, you can use it with an
interactive REPL. Alternatievly, you can provide it with the path to a JuLox file.
"""
function run_julox(args::String...)
    if length(args) > 1
        println("Usage: JuLox [script]")
        exit(64)
    elseif length(args) == 1
        _run_file(args[0])
    else
        _run_prompt()
    end
end

function _run_file(path::String)
    data = read(path)
    return _run(data)
end

function _run_prompt()
    while true
        print("> ")
        val = readline()
        if isnothing(val)
            break
        end
        _run(val)
        println()
    end
end

# Tokenizes the input and inteprets it
function _run(source::String)
    scanner = Scanner(source)
    for token in scanner.tokens
        println(token)
    end
end

function error(line::Int, message::String)
    _report(line, "", message)
end

function _report(line::Int, pos::String, message::String)
    println(
        "[line " * line * "] Error" * pos + ": " * message
    )
end