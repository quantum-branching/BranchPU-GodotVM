class_name CompilerQB extends RefCounted

##All characters that occur before an operand that specify what type of operand it is.
const OPERAND_PREFIX:PackedStringArray = ["$","#"]

const VAR_TYPES:PackedStringArray = ["int", "char", "bool", "arr", "str", "var"]

##All characters that should be interpreted as numbers.
const NUMBERS:PackedStringArray = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
const COMP:PackedStringArray = ["=",">","<",">=","<=", "=="]
const OP_1:PackedStringArray = ["*","/"]
const OP_2:PackedStringArray = [">>","<<"]
const OP_3:PackedStringArray = ["|","&","^"]
const OP_4:PackedStringArray = ["+","-"]

const QB_OPERATORS:PackedStringArray = ["+","-",">>","<<","|","&","^","="]
const ASM_OPERATORS:PackedStringArray = ["ADD","SUB","RSH","LSH","OR","AND","XOR","STA"]

const QB_SINGLE:PackedStringArray = ["return _"]
const ASM_SINGLE:PackedStringArray = ["~POP"]

var code:String

var postproc:Dictionary
var undefined:PackedByteArray
var temp:PackedByteArray
var funcPointers:Dictionary

var mainEnded:bool

var assembly:String

var error:PackedStringArray
var lastLine:int

func _init(newCode:String) -> void:
	define(newCode)

static func compile(newCode:String, ports:Array[Port] = []) -> Assembly:
	var compiler:CompilerQB = CompilerQB.new(newCode)
	if compiler.error:
		return Assembly.new("\n".join(compiler.error), true)
	return Assembly.create(compiler.assembly, ports)

func seperateArgs(text:String) -> String:
	text = text.replace(";", "\n")
	text = text.replace("*", " * ")
	text = text.replace("/", " / ")
	text = text.replace("+", " + ")
	text = text.replace("-", " - ")
	text = text.replace("(", " ( ")
	text = text.replace(")", " ) ")
	text = text.replace("[", " [ ")
	text = text.replace("]", " ] ")
	text = text.replace("<", " < ")
	text = text.replace(">", " > ")
	text = text.replace("!", " ! ")
	text = text.replace("^", " ^ ")
	text = text.replace("&", " & ")
	text = text.replace("|", " | ")
	text = text.replace("& &", "&&")
	text = text.replace("| |", "||")
	text = text.replace("<  <", "<<")
	text = text.replace(">  >", ">>")
	text = text.replace("  ", " ")
	return text

func define(newCode) -> void:
	code = seperateArgs(newCode)
	#Clear all definitions
	postproc = {}
	undefined.resize(256)
	for i in 256:
		undefined[i] = i
	#Define Variables
	for i in code.split("\n",false):
		if i.contains(" ") && VAR_TYPES.has(i.split(" ")[0].replace("\t", "")) && undefined.size():
			postproc[i.get_slice(" ", 1)] = "$" + String.num_int64(undefined[0])
			undefined.remove_at(0)
	for line in code.split("\n", false):
		if line.replace("\t", "").begins_with("func "):
			funcPointers[line.replace("\t", "").get_slice(" ", 1)] = PackedByteArray([])
			for i in line.count(", "):
				funcPointers[line.replace("\t", "").get_slice(" ", 1)].append(undefined[0])
				undefined.remove_at(0)
	#Initialize Result and Defintions
	var result:String = ""
	#Replace tokens with their definitions
	for line in code.split("\n", false):
		for arg in line.split(" ", false):
			if postproc.keys().has(arg):
				result += postproc[arg]
			else:
				result += arg
			result += " "
		result += "\n"
	code = result.replace(" \n","\n")
	for i in (code.count("\n") + 1):
		assembly += toAssembly(toPostFix(i))
	if !assembly.containsn("NOP"):
		assembly += "NOP\n"

##Converts an infix expression (as a [String]) to a postfix expression (as a [PackedStringArray]). [br]
##An infix expression contains an operator surround by operands such as [code] 2 * 5 + 3 [/code]. [br]
##A postfix expression has the operator after the operands such as [code] 2 5 * 3 + [/code].
func toPostFix(line:int) -> PackedStringArray:
	var result:PackedStringArray = []
	var stack:PackedStringArray = []
	var args:PackedStringArray = code.get_slice("\n", line).replace("\t", "").split(" ",false)
	
	var storage:String = ""
	
	lastLine = line + 1
	
	if args && args[0] == "#asm":
		return [code.get_slice("\n", line).replace("\t", "")]
	
	while args:
		if funcPointers.keys().has(args[0]):
			if code.get_slice("\n", line).contains("func "):
				if !mainEnded:
					result.append("~NOP")
					mainEnded = true
				result.append("~." + args[0])
			else:
				stack.append("~PSH 0 ." + args[0])
		if QB_SINGLE.has("_ " + args[0]):
			result.append(ASM_SINGLE[QB_SINGLE.find("_ " + args[0])])
		if NUMBERS.has(args[0].substr(0,1)) || OPERAND_PREFIX.has(args[0].substr(0,1)):
			if args.has("="):
				storage = args[0]
			else:
				result.append(args[0])
		
		if OP_1.has(args[0]):
			while stack.size() && OP_1.has(stack[stack.size() - 1]):
				result.append(stack[stack.size() - 1])
				stack.remove_at(stack.size() - 1)
			stack.append(args[0])
		if OP_2.has(args[0]):
			while stack.size() && (OP_1.has(stack[stack.size() - 1]) || OP_2.has(stack[stack.size() - 1])):
				result.append(stack[stack.size() - 1])
				stack.remove_at(stack.size() - 1)
			stack.append(args[0])
		if OP_3.has(args[0]):
			while stack.size() && (OP_1.has(stack[stack.size() - 1]) || OP_2.has(stack[stack.size() - 1]) || OP_3.has(stack[stack.size() - 1])):
				result.append(stack[stack.size() - 1])
				stack.remove_at(stack.size() - 1)
			stack.append(args[0])
		if OP_4.has(args[0]):
			while stack.size() && (OP_1.has(stack[stack.size() - 1]) || OP_2.has(stack[stack.size() - 1]) || OP_3.has(stack[stack.size() - 1]) || OP_4.has(stack[stack.size() - 1])):
				result.append(stack[stack.size() - 1])
				stack.remove_at(stack.size() - 1)
			stack.append(args[0])
		if QB_SINGLE.has(args[0] + " _"):
			while stack.size() && (OP_1.has(stack[stack.size() - 1]) || OP_2.has(stack[stack.size() - 1]) || OP_3.has(stack[stack.size() - 1]) || OP_4.has(stack[stack.size() - 1])):
				result.append(stack[stack.size() - 1])
				stack.remove_at(stack.size() - 1)
			stack.append(ASM_SINGLE[QB_SINGLE.find(args[0] + " _")])
		if COMP.has(args[0]):
			while stack.size() && (OP_1.has(stack[stack.size() - 1]) || OP_2.has(stack[stack.size() - 1]) || OP_3.has(stack[stack.size() - 1]) || OP_4.has(stack[stack.size() - 1])):
				result.append(stack[stack.size() - 1])
				stack.remove_at(stack.size() - 1)
			stack.append(args[0])
		if args[0] == "(":
			stack.append("(")
		if args[0] == ")":
			while stack.size() && stack[stack.size() - 1] != "(":
				result.append(stack[stack.size() - 1])
				stack.remove_at(stack.size() - 1)
			if stack.size():
				stack.remove_at(stack.size() - 1)
		args.remove_at(0)
	while stack.size():
		if stack[stack.size() - 1] == "=":
			result.append(storage)
		result.append(stack[stack.size() - 1])
		stack.remove_at(stack.size() - 1)
	return result

##Converts a postfix expression (as a [PackedStringArray]) to assembly (as a [String]).
func toAssembly(postfix:PackedStringArray) -> String:
	var result:String = ""
	var stack:PackedStringArray = []
	var expArgs:PackedByteArray
	var lastOP:String
	
	if postfix && postfix[0].begins_with("#asm "):
		return postfix[0].replace("#asm ", "") + "\n"
	
	for i in postfix:
		i = i.replace("\n", "")
		if expArgs:
			expArgs.remove_at(0)
		elif i.begins_with("~"):
			#TODO: Add arguments
			result += i.erase(0) + ";\n"
			stack.append("$XX")
		elif stack && funcPointers.keys().has(stack[stack.size() - 1]):
			stack.remove_at(stack.size() - 1)
		elif funcPointers.keys().has(i):
			expArgs = funcPointers[i]
			stack.append(i)
		elif OPERAND_PREFIX.has(i.substr(0,1)) || NUMBERS.has(i.substr(0,1)):
			if NUMBERS.has(i.substr(0,1)):
				i = "#" + i
			stack.append(i)
		elif QB_OPERATORS.has(i):
			lastOP = i
			if stack.size() > 1:
				if stack[stack.size() - 2] != "$XX":
					for reg in temp:
						if !stack.has("$"+str(reg)):
							undefined.append(reg)
					if stack.has("$XX"):
						stack[stack.find("$XX")] = "$" + String.num_int64(undefined[undefined.size() - 1])
						temp.append(undefined[undefined.size() - 1])
						result += "STA " + "$" + String.num_int64(undefined[undefined.size() - 1]) + ";\n"
						undefined.remove_at(undefined.size() - 1)
					if stack[stack.size() - 2].begins_with("$"):
						result += "LDA " + stack[stack.size() - 2] + ";\n"
					else:
						result += "LDI " + stack[stack.size() - 2] + ";\n"
					if stack.size() > 1:
						stack.remove_at(stack.size() - 2)
					else:
						error.append("Error 01: Expected a value after \"" + lastOP + "\" on line " + String.num_int64(lastLine))
						continue
			if stack[stack.size() - 1] != "$XX":
				result += ASM_OPERATORS[QB_OPERATORS.find(i)] + " " + stack[stack.size() - 1] + ";\n"
			stack[stack.size() - 1] = "$XX"
	return result
