
function report(line::Int, pos::String, message::String)
    println(
        "[line " * string(line) * "] Error" * pos * ": " * message
    )
end

