module parser

import token
import scanner
import ast

struct Parser {
mut:
	scanner &scanner.Scanner
	end     bool
}

pub fn new_parser(input string) &Parser {
	return &Parser{
		scanner: scanner.new_scanner(input)
	}
}

pub fn (mut parser Parser) parse_all() &ast.File {
	mut file := &ast.File{}
	mut expr := parser.parse_next() or { return file }
	for !parser.end {
		file.expr << expr
		expr = parser.parse_next() or {
			eprintln(err)
			break
		}
	}
	file.expr << expr
	return file
}

fn (mut parser Parser) parse_next() ?ast.Expr {
	mut expr := ast.Expr{}
	match parser.scanner.next() {
		.text {
			expr = parser.parse_text()
		}
		.asterisk {
			expr = parser.parse_text()
		}
		.pound {
			expr = parser.parse_header()
		}
		.nl {
			expr = ast.NewLineExpr{}
		}
		.invalid {
			return error('Token is invalid')
		}
		else {
			parser.end = true
			expr = ast.NewLineExpr{}
		}
	}
	return expr
}

fn (mut parser Parser) parse_text() ast.TextExpr {
	mut expr := []ast.Expr{}
	mut n := parser.scanner.last
	for (n in [.text, .nl, .asterisk, .whitespace]) {
		match n {
			.text, .whitespace {
				expr << ast.StringExpr{string(parser.scanner.lit)}
			}
			.nl {
				expr << ast.NewLineExpr{}
			}
			.asterisk, .underscore {
				if parser.scanner.check_next(parser.scanner.lit[0]) {
					// Bold
					lit := parser.scanner.lit[0]
					parser.scanner.next_to(string([lit, lit]))
					expr << ast.BoldExpr{string(parser.scanner.lit)}
				} else {
					parser.scanner.next_to(string(parser.scanner.lit))
					expr << ast.ItalicExpr{string(parser.scanner.lit)}
				}
			}
			else {
				eprintln('Something went wrong')
				return ast.TextExpr{}
			}
		}
		n = parser.scanner.next()
	}
	return ast.TextExpr{
		expr: expr
	}
}

fn (mut parser Parser) parse_header() ast.HeaderExpr {
	mut level := 1
	for {
		parser.expect(.whitespace, .pound) or {
			eprintln(err)
			return ast.HeaderExpr{}
		}
		if parser.scanner.last != .pound {
			break
		}
		level++
	}
	parser.expect(.text) or {
		eprintln(err)
		return ast.HeaderExpr{}
	}
	text := string(parser.scanner.lit)
	return ast.HeaderExpr{
		level: level
		text: text
	}
}

fn (mut parser Parser) expect(token ...token.Token) ? {
	t := parser.scanner.next()
	if t !in token {
		return error('Unexpected token (expected `$token` but got `$t`')
	}
}
