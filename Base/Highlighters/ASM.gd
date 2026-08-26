class_name AssemblyHighligher extends SyntaxHighlighter

var container:Control

const PREPROCESSOR:Color = Color(.85,.25,.25)
const PRE_ARG:Color = Color(.85,.85,.25)
const COMMENT:Color = Color(.5,.5,.5)
const NUMBER:Color = Color(0,.75,.25)
const REGISTER:Color = Color(0,.35,0)
const RELATIVE:Color = Color(.25,.25,.75)
const OP:Color = Color(.8,.4,.2)

const OPERATIONS:PackedStringArray = ["JMP", "ADD", "SUB", "LSH", "RSH", "AND", "OR", "XOR", "LDA", "STA", "LDI", "CND", "PSH", "POP", "CST", "CMP", "NOP", "RPA", "RPR", "WPA", "WPR","ICP"]

func _init(newContainer:Control):
	container = newContainer

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var result:Dictionary = {}
	var text:String = container.text.get_slice("\n", line)
	for x in text.length():
		if text.substr(x,1) == "#":
			result.set(x, {"color":PREPROCESSOR})
		if text.substr(x,7).to_lower() == "#import" || text.substr(x,7).to_lower() == "#define":
			result.set(x + 7, {"color":PRE_ARG})
		if text.substr(x,1) == ";":
			result.set(x, {"color":COMMENT})
			return result
		if ["0","1","2","3","4","5","6","7","8","9"].has(text.substr(x,1)):
			result.set(x, {"color":NUMBER})
		if text.substr(x,1) == ".":
			result.set(x, {"color":RELATIVE})
		if OPERATIONS.has(text.substr(x,3).replace(" ", "")):
			result.set(x, {"color":OP})
	return result
