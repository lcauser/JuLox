abstract type Expr end
export Binary, Grouping, Literal, Unary


struct Binary <: Expr
   left::Expr
   operator::Token
   right::Expr
end 

struct Grouping <: Expr
   expression::Expr
end 

struct Literal <: Expr
   value::LiteralUnion
end 

struct Unary <: Expr
   operator::Token
   right::Expr
end 

