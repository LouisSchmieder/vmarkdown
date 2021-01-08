module parser

import token
import scanner
import ast

struct Parser {
mut:
	scanner &scanner.Scanner
}

pub fn new_parser(input string) &Parser {
	return &Parser{
		scanner: scanner.new_scanner(input)
	}
}

pub fn (mut parser Parser) parse_all() &ast.File {
	mut file := &ast.File{}
	mut expr := parser.parse_next() or { return file }
	for {
		file.expr << expr
		expr = parser.parse_next() or { break }
	}
	return file
}

fn (mut parser Parser) parse_next() ?ast.Expr {
	mut expr := ast.Expr{}
	match parser.scanner.next() {
		.text { expr = parser.parse_text() }
		.pound { expr = parser.parse_header() ? }
		.invalid { return error('Token is invalid') }
		else { return error('EOF reached') }
	}
}

fn (mut parser Parser) parse_text() ast.Expr {
	mut text := string(parser.scanner.lit)
	mut n := parser.scanner.next()
	for n == .text || n == .nl {
		text += string(parser.scanner.lit)
		n = parser.scanner.next()
	}
	return ast.TextExpr{
		text: text
	}
}

fn (mut parser Parser) parse_header() ?ast.Expr {
	mut level := 1
	for parser.scanner.next() == .pound {
		level++
	}
	parser.expect(.whitespace, .text) ?
	if parser.scanner.last == .whitespace {
		parser.expect(.text)
	}
	text := string(parser.scanner.lit)
	parser.expect(.whitespace)
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
