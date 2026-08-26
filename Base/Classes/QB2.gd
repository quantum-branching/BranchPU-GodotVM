class_name CompilerQB2 extends RefCounted

const REGISTER_COUNT:int = 256

var freeRegisters:Array[int] = []
var usedRegisters:Array[int] = []
var variableStack:Array[String] = []

func _init() -> void:
	freeRegisters.resize(REGISTER_COUNT)
	for i in REGISTER_COUNT:
		freeRegisters[i] = i

## Allocates a register to [param variable]
func allocv(variable:String):
	var x:int = freeRegisters.pop_back()
	usedRegisters.push_back(x)
	variableStack.push_back(variable)
	return x

## Frees the last [param n] variables
func freev(n:int) -> void:
	for i in n:
		freeRegisters.push_back(usedRegisters.pop_back())
		variableStack.pop_back()

func tokenize(code:String):
	var tokens:Array[Token] = []
	while(code.length):
		if code.begins_with("\""):
			tokens.append(Token.new(Token.STRING, code.substr(1, code.find("\"", 1) - 1)))
			code = code.substr(code.find("\"", 1) + 1, -1)
		elif code.begins_with("'"):
			if code[int(code[1] == "\\") + 2] != '\'':
				tokens.append(Token.new(Token.ERROR, "Char type does not accept a string: try '" + code[int(code[1] == "\\") + 1] + "' instead"))
				return tokens
			tokens.append(Token.new(Token.CHAR, code.substr(1, int(code[1] == "\\") + 1)))
			code = code.substr(3 + int(code[1] == "\\"), -1)
		elif code.substr(0,1).is_valid_int():
			var length = 1
			while code.substr(0,length + 1).is_valid_int():
				length += 1
			tokens.append(Token.new(Token.INT, code.substr(0, length)))
			code = code.substr(length + 1, -1)
		elif code.is_valid_ascii_identifier():
			var length = 1
			while code.substr(0, length + 1).is_valid_ascii_identifier():
				length += 1
			if code[length] == '(':
				pass
		else:
			pass
	return tokens

class Token:
	var type:int;
	var content:String;
	
	const ERROR = -1
	const OPENSCOPE = 0
	const CLOSESCOPE = 1
	const FUNC = 2
	const VARIABLE = 3
	const PARAM = 4
	const LPAREN = 5
	const RPAREN = 6
	const OPERATOR = 7
	const INT = 8
	const ARRAY = 9
	const CHAR = 10
	const STRING = 11
	
	@warning_ignore("shadowed_variable")
	func _init(type:int, content:String) -> void:
		self.type = type
		self.content = content
