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

pub fn (mut scanner Scanner) next_to(pattern string) {
	scanner.lit = []byte{}
	scanner.head += pattern.len - 1
	for {
		s := scanner.input[scanner.head..scanner.head + pattern.len]
		if scanner.check_next_eof() || s == pattern {
			if scanner.check_next_eof() {
				scanner.lit << scanner.input[scanner.head]
			}
			break
		}
		scanner.lit << scanner.input[scanner.head]
		scanner.head++
	}
	scanner.head += pattern.len
}

pub fn (mut scanner Scanner) last_two() string {
	return string([scanner.input[scanner.head - 1], scanner.input[scanner.head]])
}

pub fn (mut scanner Scanner) check_next(c byte) bool {
	return scanner.input[scanner.head] == c
}

pub fn (mut scanner Scanner) back(amount int) {
	scanner.head -= amount
}

fn (mut scanner Scanner) scan() token.Token {
	scanner.lit = []byte{}
	if scanner.check_eof() {
		return .eof
	}
	mut c := scanner.input[scanner.head]
	if c in token.non_text.bytes() {
		scanner.lit << c
		return scanner.match_token(c)
	}
	return scanner.scan_text()
}

fn (mut scanner Scanner) check_eof() bool {
	return scanner.head >= scanner.input.len
}

fn (mut scanner Scanner) check_next_eof() bool {
	return scanner.head + 1 >= scanner.input.len
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
		`:` { t = .ddot }
		else {}
	}
	return t
}

pub fn (mut scanner Scanner) next_str() string {
	return string([scanner.input[scanner.head + 1]])
}

fn (mut scanner Scanner) scan_text() token.Token {
	mut c := scanner.input[scanner.head]
	mut l := byte(0x00)
	for {
		l = c
		c = scanner.input[scanner.head]
		if c == `\n` {
			scanner.head--
			break
		}
		if ((c !in token.non_text.bytes() || l == `\\`)) && !scanner.check_next_eof() {
			scanner.lit << c
			scanner.head++
		} else {
			break
		}
	}
	return .text
}
