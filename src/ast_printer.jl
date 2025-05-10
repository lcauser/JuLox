function print_expression(expr::Binary)
    return parenthesize(expr.operator.lexeme, expr.left, expr.right)
end

function print_expression(expr::Grouping)
    return parenthesize("group", expr.expression)
end

function print_expression(expr::Literal)
    isnothing(expr.value) && return "nil"
    return string(expr.value)
end

function print_expression(expr::Unary)
    return parenthesize(expr.operator.lexeme, expr.right)
end

function parenthesize(name::String, exprs::Expr...)
    str = "(" * name 
    for expr in exprs
        str *= " " * print_expression(expr)
    end
    str *= ")"
    return str
end