module token

const (
	non_text = '`*_{}[]<>()#+-.!|\n '
)

pub enum Token {
	eof
	invalid
	text
	nl // \n
	whitespace //  
	backtick // `
	asterisk // *
	underscore // _
	cbl // {
	cbr // }
	bl // [
	br // ]
	abl // <
	abr // >
	rbl // (
	rbr // )
	pound // #
	plus // +
	minus // -
	dot // .
	ex // !
	pipe // |
}
