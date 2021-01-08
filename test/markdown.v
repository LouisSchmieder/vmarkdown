module main

import vmarkdown
import os

fn main() {
	test := os.read_file('input1.md') or { panic(err) }
	compiled := vmarkdown.compile_markdown(test)
	os.write_file('output1.html', compiled)
}
