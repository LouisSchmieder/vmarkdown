module vmarkdown

import parser
import gen

pub fn compile_markdown(input string) string {
	mut parser := parser.new_parser(input)
	file := parser.parse_all()
	mut gen := gen.new_html_gen(file)
	return gen.gen()
}
