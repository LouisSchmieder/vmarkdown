module ast

pub type Expr = EofExpr | HeaderExpr | TextExpr

pub struct TextExpr {
	text string
}

pub struct HeaderExpr {
	level int
	text  string
}

pub struct EofExpr {}

// Placeholder
