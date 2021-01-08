module ast

pub type Expr = BoldExpr | HeaderExpr | ItalicExpr | NewLineExpr | StringExpr | TextExpr
	

pub struct TextExpr {
pub:
	expr []Expr
}

pub struct StringExpr {
pub:
	text string
}

pub struct NewLineExpr {}

pub struct HeaderExpr {
pub:
	level int
	text  string
}

pub struct BoldExpr {
pub:
	text string
}

pub struct ItalicExpr {
pub:
	text string
}
