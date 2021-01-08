module scanner

import token

struct Scanner {
	input string
mut:
	head  int
pub mut:
	lit   []byte
	last  token.Token
}

pub fn new_scanner(input string) &Scanner {
	return &Scanner{
		input: input
		head: 0
		last: .invalid
	}
}

pub fn (mut scanner Scanner) next() token.Token {
	t := scanner.scan()
	scanner.head++
	scanner.last = t
	return t
}

fn (mut scanner Scanner) scan() token.Token {
	scanner.lit = []byte{}
	if scanner.check_eof() {
		return .eof
	}
	mut c := scanner.input[scanner.head]
	if c in token.non_text.bytes() {
		if c != ` ` || scanner.last != .text {
			scanner.lit << c
			return scanner.match_token(c)
		}
	}
	return scanner.scan_text()
}

fn (mut scanner Scanner) check_eof() bool {
	return scanner.head >= scanner.input.len
}

fn (mut scanner Scanner) match_token(c byte) token.Token {
	mut t := token.Token.invalid
	match c {
		` ` { t = .whitespace }
		`\`` { t = .backtick }
		`*` { t = .asterisk }
		`_` { t = .underscore }
		`{` { t = .cbl }
		`}` { t = .cbr }
		`[` { t = .bl }
		`]` { t = .br }
		`<` { t = .abl }
		`>` { t = .abr }
		`(` { t = .rbl }
		`)` { t = .rbr }
		`#` { t = .pound }
		`+` { t = .plus }
		`-` { t = .minus }
		`.` { t = .dot }
		`!` { t = .ex }
		`|` { t = .pipe }
		`\n` { t = .nl }
		else {}
	}
	return t
}

fn (mut scanner Scanner) scan_text() token.Token {
	mut c := scanner.input[scanner.head]
	mut l := byte(0x00)
	for (c !in token.non_text.bytes() ||
		(c in token.non_text.bytes() && l == `\\`)) &&
		!scanner.check_eof() {
		l = c
		c = scanner.input[scanner.head]
		if c == `\n` {
			scanner.head--
			break
		}
		scanner.lit << c
		scanner.head++
	}
	return .text
}
