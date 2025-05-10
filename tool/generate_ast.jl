function main(args::String...)
    if length(args) != 1
        throw(ArgumentError("Usage: generate_ast <output directory>"))
    end
    output_dir = args[1]
    
    types = [
        "Binary   : left::Expr, operator::Token, right::Expr",
        "Grouping : expression::Expr",
        "Literal  : value::LiteralUnion",
        "Unary    : operator::Token, right::Expr"
    ]

    define_ast(output_dir, "test", types)
end

function define_ast(output_dir::AbstractString, base_name::AbstractString, types::Vector{<:AbstractString})
    path = joinpath(output_dir, base_name * ".jl")
    open(path, "w") do file
        write(file, "abstract type Expr end\n\n")
        for type in types 
            parsed_string = split(type, " : ")
            type_name = strip(parsed_string[1])
            fields = strip(parsed_string[2])
            define_type(file, type_name, fields)
        end
    end
end

function define_type(
    file::IOStream,
    type_name::AbstractString,
    fields::AbstractString
)
    write(file, "export "*type_name*"\n")
    write(file, "struct "*type_name*" <: Expr\n")

    fields = split(fields, ",")
    for field in fields
        write(file, "   "*strip(field)*"\n")
    end

    write(file, "end \n\n")
end