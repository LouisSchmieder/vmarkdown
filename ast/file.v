module ast

pub struct File {
pub mut:
	expr []Expr
	vars map[string]VarExpr
}
