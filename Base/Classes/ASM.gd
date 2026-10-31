class_name Assembly extends RefCounted

var cpu:CPU

var code:String

var removeBlank:bool = false

var labels:Dictionary = {}

var functions:Dictionary = {}

var implications:Dictionary = {}

var error:bool = false

func _init(newCode:String = "", newError:bool = false) -> void:
	if newError:
		error = true
		code = newCode
		return
	
	if newCode.containsn("#removeblank"):
		removeBlank = true
		newCode = newCode.replacen("#removeBlank", "")
	newCode = define(implies(import(newCode.replace("\r", "")).replace("\t", "")))
	
	var counter:int = 1
	
	for line in newCode.split("\n",!removeBlank):
		if line.contains(";"):
			line = line.get_slice(";", 0)
		if line.begins_with("."):
			labels[line.get_slice(" ", 0)] = String.num_int64(counter)
			if line.contains(" ") && line.split(" ", false, 1).size() > 1:
				line = line.split(" ", false, 1)[1]
			else:
				line = ""
		if line.replace("\t", "").begins_with("NOP"):
			line = "JMP " + String.num_int64(counter)
		if line || !removeBlank:
			counter += 1
			code += line + "\n"
	
	for i in labels.keys():
		code = code.replace(i, labels[i])
	
	code = code.replace("\\","\n")
	
	while code.contains("  "):
		code = code.replace("  ", " ")
	cpu = assemble()

@warning_ignore("shadowed_variable")
static func create(code:String = "", ports:Array[Port] = []) -> Assembly:
	var result:Assembly = Assembly.new(code, false)
	result.cpu.ports = ports
	for i:Port in ports:
		if i:
			i.reset()
	return result

func import(newCode:String) -> String:
	var result:String = ""
	for line in newCode.split("\n"):
		if line.begins_with("#import "):
			result += FileAccess.get_file_as_string("res://Lang-ASM/Packages/" + line.get_slice(" ", 1).to_lower() + ".bpu").replace("\r","")
		else:
			result += line + "\n"
	return result

func define(newCode:String) -> String:
	var result:String = ""
	for line in newCode.split("\n"):
		if line.begins_with("#define "):
			labels[line.get_slice(" ", 1)] = line.get_slice(" ", 2)
		else:
			result += line + "\n"
	return result

func implies(newCode:String) -> String:
	var result:String = ""
	for line in newCode.split("\n"):
		if line.begins_with("#implies ") && line.contains(" ") && line.split(" ",false, 1)[1].contains(" "):
			implications[line.get_slice(" ", 1)] = line.split(" ",false, 2)[2]
		else:
			result += line + "\n"
	return result

func stdout(format:String) -> void:
	format = format.c_unescape()
	format = format.replace("\"","")
	format = format.format([cpu.accumulator], "{A}")
	format = format.format(Array(cpu.memory))
	print(format)

func assemble() -> CPU:
	var result:PackedByteArray = []
	var current:PackedByteArray = [0, 0]
	const OPERATIONS:PackedStringArray = ["JMP", "ADD", "SUB", "LSH", "RSH", "AND", "OR", "XOR", "LDA", "STA", "CND", "PSH", "POP", "CMP", "ICP", "STK", "RPA", "RPR", "WPA", "WPR"]
	const IMEDOPS:PackedStringArray = ["ADD", "SUB", "LSH", "RSH", "AND", "OR", "XOR"]
	const TRIOPS:PackedStringArray = ["JMP", "PSH", "CND", "CMP", "ICP", "STK", "RPR", "RPA", "WPR", "WPA"]
	const JUMPS:PackedStringArray = ["JMP", "PSH", "CND"]
	for i in code.replace("\t", "").split("\n"):
		var op:String = i.get_slice(" ", 0)
		var arg1:String = i.get_slice(" ", 1)
		var arg2:String = i.get_slice(" ", 2)
		if OPERATIONS.has(op):
			current[0] = int(IMEDOPS.has(op) && arg1.contains("#") || op == "STK") + (OPERATIONS.find(op) << 3)
			if TRIOPS.has(op):
				var zeroIndex:int = int(JUMPS.has(op))
				if int(arg1) > 256 || arg2 == "":
					current[0] += ((int(arg1) - zeroIndex) >> 8) & 7
					current[1] = (int(arg1) - zeroIndex) & 255
				else:
					current[1] = (int(arg2) - zeroIndex) & 255
					current[0] += (int(arg1) - int(current[1] * zeroIndex == 255)) & 7
			else:
				current[1] = int(arg1) & 255
			result.append_array(current)
		elif op == "LDI":
			result.append(65)
			result.append(int(arg1) & 255)
		elif op == "CST":
			result.append_array([65, int(arg1) & 255, 72, 0])
	return CPU.new(result)

func _to_string() -> String:
	if error:
		return code
	var result:String = "Line: " + String.num_int64((cpu.instruction >> 1) + 1)
	result += "\nAccumulator: \n\t"
	result += String.num_int64(cpu.accum)
	result += "\nMemory: \n"
	for i in cpu.regs:
		result += "\t" + String.num_int64(i) + "\n"
	return result


static func truncate(buffer:PackedByteArray) -> PackedByteArray:
	var result:PackedByteArray = buffer.duplicate()
	while !result.get(result.size() - 1):
		result.remove_at(result.size() - 1)
	if result.size() % 2:
		result.append(0)
	return result
