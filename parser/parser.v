module parser

import token
import scanner
import ast

struct Parser {
mut:
	scanner &scanner.Scanner
	end     bool
	values  map[string]ast.VarExpr
	in_text bool
}

pub fn new_parser(input string) &Parser {
	return &Parser{
		scanner: scanner.new_scanner(input)
	}
}

pub fn (mut parser Parser) parse_all() &ast.File {
	mut file := &ast.File{}
	mut expr := parser.parse_next()
	for !parser.end {
		file.expr << expr
		expr = parser.parse_next()
		if parser.end {
			break
		}
	}
	file.expr << expr
	file.vars = parser.values
	return file
}

fn (mut parser Parser) parse_next() ast.Expr {
	mut expr := ast.Expr{}
	match parser.scanner.next() {
		.text {
			if parser.in_text {
				expr = parser.parse_string()
			} else {
				expr = parser.parse_text()
			}
		}
		.asterisk, .underscore {
			if parser.scanner.check_next(parser.scanner.lit[0]) {
				// Bold
				lit := parser.scanner.lit[0]
				parser.scanner.next_to(string([lit, lit]))
				expr = ast.BoldExpr{string(parser.scanner.lit)}
			} else {
				parser.scanner.next_to(string(parser.scanner.lit))
				expr = ast.ItalicExpr{string(parser.scanner.lit)}
			}
		}
		.pound {
			expr = parser.parse_header()
		}
		.nl {
			expr = ast.NewLineExpr{}
		}
		.bl {
			expr = parser.parse_link()
		}
		.whitespace {
			expr = ast.WhitespaceExpr{}
		}
		.abr {
			expr = parser.parse_blockquote()
		}
		.ex {
			if parser.scanner.check_next(`[`) {
				expr = parser.parse_image()
			} else {
				expr = parser.parse_text()
			}
		}
		.invalid {
		}
		else {
			parser.end = true
			expr = ast.InvalidExpr{'The END'}
		}
	}
	return expr
}

fn (mut parser Parser) parse_text() ast.TextExpr {
	mut expr := []ast.Expr{}
	parser.in_text = true
	expr << parser.parse_string()
	for {
		e := parser.parse_next()
		match e {
			ast.HeaderExpr, ast.VarExpr, ast.NewLineExpr, ast.InvalidExpr, ast.BlockquoteExpr {
				break
			}
			else {
				expr << e
			}
		}
	}
	parser.in_text = false
	return ast.TextExpr{
		expr: expr
	}
}

fn (mut parser Parser) parse_string() ast.Expr {
	e := ast.StringExpr{string(parser.scanner.lit)}
	parser.scanner.back(1)
	return e	
}

fn (mut parser Parser) parse_header() ast.Expr {
	mut level := 1
	for {
		parser.expect(.whitespace, .pound) or {
			eprintln(err)
			return ast.InvalidExpr{err}
		}
		if parser.scanner.last != .pound {
			break
		}
		level++
	}
	parser.scanner.next_to('\n')
	text := string(parser.scanner.lit)
	return ast.HeaderExpr{
		level: level
		text: text
	}
}

fn (mut parser Parser) parse_image() ast.Expr {
	parser.expect(.bl) or {
		error(err)
		return ast.InvalidExpr{err}
	}
	parser.scanner.next_to(']')
	text := parser.scanner.lit[0..parser.scanner.lit.len - 1]
	parser.scanner.back(1)
	parser.expect(.br) or {
		error(err)
		return ast.InvalidExpr{err}
	}
	parser.expect(.bl, .rbl) or {
		error(err)
		return ast.InvalidExpr{err}
	}
	mut end_expect := token.Token.eof
	mut is_var := false
	if parser.scanner.last == .bl {
		end_expect = .br
		parser.scanner.next_to(']')
		is_var = true
	} else if parser.scanner.last == .rbl {
		end_expect = .rbr
		parser.scanner.next_to(')')
		is_var = false
	}
	link := string(parser.scanner.lit)
	parser.scanner.back(1)
	parser.expect(end_expect) or {
		eprintln(err)
		return ast.InvalidExpr{err}
	}

	return ast.ImageExpr{
		text: string(text)
		from_var: is_var
		link: link
	}
}

fn (mut parser Parser) parse_link() ast.Expr {
	parser.scanner.next_to(']')
	text := parser.scanner.lit[0..parser.scanner.lit.len - 1]
	parser.scanner.back(1)
	parser.expect(.br) or {
		error(err)
		return ast.InvalidExpr{err}
	}

	if parser.scanner.check_next(`:`) {
		return parser.parse_var(string(text))
	}

	parser.expect(.bl, .rbl) or {
		error(err)
		return ast.InvalidExpr{err}
	}
	mut end_expect := token.Token.eof
	mut is_var := false
	if parser.scanner.last == .bl {
		end_expect = .br
		parser.scanner.next_to(']')
		is_var = true
	} else if parser.scanner.last == .rbl {
		end_expect = .rbr
		parser.scanner.next_to(')')
		is_var = false
	}
	link := string(parser.scanner.lit)
	parser.scanner.back(1)
	parser.expect(end_expect) or {
		eprintln(err)
		return ast.InvalidExpr{err}
	}

	return ast.LinkExpr{
		text: string(text)
		from_var: is_var
		link: link
	}
}

fn (mut parser Parser) parse_var(name string) ast.Expr {
	parser.expect(.ddot) or {
		error(err)
		return ast.InvalidExpr{err}
	}
	parser.expect(.whitespace) or {
		error(err)
		return ast.InvalidExpr{}
	}
	parser.scanner.next_to('\n')
	mut value := string(parser.scanner.lit)
	ret := ast.VarExpr{
		name: name
		value: value
	}
	parser.values[name] = ret
	return ret
}

fn (mut parser Parser) parse_blockquote() ast.Expr {
	mut expr := []ast.Expr{}
	expr << parser.parse_blockquote_line()
	for parser.scanner.next() == .abr {
		expr << parser.parse_blockquote_line()
	}
	parser.scanner.back(parser.scanner.lit.len)
	return ast.BlockquoteExpr{expr}
}

fn (mut parser Parser) parse_blockquote_line() []ast.Expr {
	mut expr := []ast.Expr{}
	parser.in_text = true
	parser.expect(.whitespace) or {
		error(err)
		return [ast.Expr(ast.InvalidExpr{err})]
	}
	for {
		e := parser.parse_next()
		match e {
			ast.HeaderExpr, ast.VarExpr, ast.InvalidExpr, ast.BlockquoteExpr {
				break
			}
			ast.NewLineExpr {
				expr << e
				return expr
			}
			else {
				expr << e
			}
		}
	}
	parser.in_text = false
	return [ast.Expr(ast.InvalidExpr{'Something went wrong'})]
}

fn (mut parser Parser) expect(token ...token.Token) ? {
	t := parser.scanner.next()
	if t !in token {
		return error('Unexpected token (expected `$token` but got `$t`')
	}
}
