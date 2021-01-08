module ast

pub type Expr = BoldExpr | HeaderExpr | ItalicExpr | NewLineExpr | StringExpr | TextExpr | InvalidExpr | VarExpr | LinkExpr | ImageExpr | WhitespaceExpr | BlockquoteExpr
	

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

pub struct LinkExpr {
pub:
	text string
	from_var bool
	link string
}

pub struct ImageExpr {
pub:
	text string
	from_var bool
	link string
}

pub struct WhitespaceExpr {}

pub struct VarExpr {
pub:
	name string
	value string
}

pub struct BlockquoteExpr {
pub:
	expr []Expr
}

pub struct InvalidExpr {
pub: 
	text string
} // Helper
