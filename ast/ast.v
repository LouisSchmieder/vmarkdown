module ast

pub type Expr = TextExpr | HeaderExpr | EofExpr | ErrorExpr

pub struct TextExpr {
	text string
}

pub struct HeaderExpr {
	level int
	text string
}

pub struct EofExpr {} // Placeholder

pub struct ErrorExpr {
	str string
}