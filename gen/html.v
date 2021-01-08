module gen

import strings
import ast

struct HTMLGen {
mut:
	sb   strings.Builder
	file &ast.File
}

pub fn new_html_gen(file &ast.File) &HTMLGen {
	return &HTMLGen{
		sb: strings.Builder{}
		file: file
	}
}

pub fn (mut gen HTMLGen) gen() string {
	gen.sb.writeln('<!--- Markdown translated by VMarkddown -->')
	for expr in gen.file.expr {
		gen.expr(expr)
	}
	return gen.sb.str()
}

fn (mut gen HTMLGen) expr(node ast.Expr) {
	match node {
		ast.TextExpr {
			gen.sb.write('<p>')
			for expr in node.expr {
				gen.expr(expr)
			}
			gen.sb.write('</p>')
		}
		ast.StringExpr {
			gen.sb.write(node.text)
		}
		ast.NewLineExpr {
			gen.sb.writeln('<br>')
		}
		ast.BoldExpr {
			gen.sb.write('<strong>$node.text</strong>')
		}
		ast.ItalicExpr {
			gen.sb.write('<em>$node.text</em>')
		}
		ast.HeaderExpr {
			id := node.text.to_lower().replace(' ', '_')
			gen.sb.write('<h$node.level id="$id">$node.text</h$node.level>')
		}
	}
}
