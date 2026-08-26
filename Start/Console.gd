extends Node
var compiler:Assembly
var code:String
var running:bool
var filepath:String

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		running = true
		print("---------------------------- BranchPU ----------------------------")
		print("<file>         - opens up <file> and changes filepath to <file>")
		print("code           - prints out all code contained in current file")
		print("compile        - compiles this file and prints the results")
		print("compile <file> - compiles this file and writes it to <file>")
		print("edit           - opens VECEDIT, a terminal text editor")
		print("exit           - exits this instance of the BranchPU")
		print("path <file>    - changes the reference filepath")
		print("run            - runs the program")
		print("   <runtime>   - tells the program how long to run")
		print("   /<interval> - tells the program how long between each print")
		print("   <format>    - tells the program how to print")
		print("save           - saves the file to the filepath for this project")
	while running:
		repl()

func repl() -> void:
	var command:String = OS.read_string_from_stdin()
	var args:PackedStringArray = command.replace("\"", "").replace("\'", "").split(" ", false, 1)
	if !args.size():
		return
	if command.begins_with("\""):
		command = command.replace("\"", "")
		if !FileAccess.get_file_as_bytes(command):
			error("Unknown filepath", command)
			return
		if command.ends_with(".bpux"):
			compiler = Assembly.new("")
			compiler.cpu = CPU.new(FileAccess.get_file_as_bytes(filepath))
			return
		if command.ends_with(".bpu"):
			filepath = command
			code = FileAccess.get_file_as_string(filepath)
			compiler = Assembly.new(code)
			return
		if command.ends_with(".qb"):
			filepath = command
			code = FileAccess.get_file_as_string(filepath)
			compiler = CompilerQB.compile(code)
			return
		error("Incorrect file type", "." + command.rsplit(".", false, 1)[1])
		return
	if args[0] == "code":
		var line = 1
		var maxLength:int = String.num_int64(code.count("\n") + 1).length()
		for i in code.split("\n"):
			print(" ".repeat(maxLength - String.num_int64(line).length()) + String.num_int64(line) + "> " + i)
			line += 1
		return
	if args[0] == "compile":
		if args.size() - 1:
			filepath = args[1]
			var file:FileAccess = FileAccess.open(filepath, FileAccess.WRITE)
			if filepath.ends_with(".bpu"):
				compiler = Assembly.new(code)
			else:
				compiler = CompilerQB.compile(code)
			file.store_string(compiler.code)
			file.close()
			return
		print(compiler.code)
		return
	if args[0] == "edit":
		code = vecedit(code)
		return
	if args[0] == "exit":
		running = false
		get_tree().quit()
		return
	if args[0] == "path":
		filepath = args[1]
		code = ""
		compiler = Assembly.new(code)
		return
	if args[0] == "run":
		var cycles:int = 5000
		var interval:int = 5000
		var format:String = ""
		if !command.contains("\""):
			format = "\"Accumulator= {A}\\n"
			for i in 32:
				for j in 8:
					format += "$" + String.num_int64(i * 8 + j) + " = {" + String.num_int64(i * 8 + j) + "}\\t"
				format += "\\n"
			format += "\""
		if args.size() - 1:
			for i in args[1].get_slice("\"", 0).replace("/ ", "/").split(" "):
				if !i.to_int():
					continue
				if i.begins_with("/"):
					interval = i.to_int()
				else:
					cycles = i.to_int()
		while cycles:
			cycles -= 1
			compiler.execute(1)
			if cycles % interval == 0:
				compiler.stdout(format)
		compiler = Assembly.new(compiler.code)
		return
	if args[0] == "save":
		if args.size() - 1:
			filepath = args[1]
		var file:FileAccess = FileAccess.open(filepath, FileAccess.WRITE)
		file.store_string(code)
		file.close()
		return
	error("Unknown command", args[0])

func error(err:String, arg:String = ""):
	if arg:
		print_rich("[color=red][b]ERROR:[/b][/color] [color=F00]", err, " \"", arg, "\"","[/color]")
	else:
		print_rich("[color=red][b]ERROR:[/b][/color] [color=F00]", err, "[/color]")

##Starts VECEDIT with the specified text
func vecedit(text:String) -> String:
	var command:String
	var lines:PackedStringArray = text.split("\n")
	var line:int = lines.size()
	var verbose:bool
	
	var help = func ():
		print("<text>           - inserts text after the last location")
		print("<int>:<text>     - inserts text on line <int>")
		print("del:             - deletes the current line")
		print("del <int>:       - deletes line <int>")
		print("del <int>:<text> - replaces line <int> with <text>")
		print("print:           - prints the current text")
		print("verbose:         - prints the current text after every edit")
		print("quiet:           - removes the verbosity effect")
		print("reset:           - resets text to initial text")
		print("help:            - prints this help text")
		print("close:           - closes VECEDIT")
		print("------------------------------------------------------------------")
	print("----------------------- Welcome to VECEDIT -----------------------")
	help.call()
	while true:
		command = OS.read_string_from_stdin()
		#Address no commands
		if !command.contains(":"):
			lines.insert(line, command)
			line += 1
			continue
		#Change Line
		if command.get_slice(":", 0).to_int():
			line = command.get_slice(":", 0).to_int() - 1
			if line < 0:
				line = -line
			if line > lines.size():
				line = lines.size()
		#Commands
		if command.begins_with("del"):
			lines.remove_at(line)
		if command.begins_with("help"):
			print("------------------------------------------------------------------")
			help.call()
		if command.begins_with("close:"):
			print("------------------------ Exiting  VECEDIT ------------------------")
			return "\n".join(lines)
		#Insert text after commands
		if command.get_slice(":", 1):
			lines.insert(line, command.get_slice(":", 1))
			line += 1
		#Visual commands
		if command.begins_with("reset"):
			lines = text.split("\n")
		if command.begins_with("verbose"):
			verbose = true
		if command.begins_with("print") || verbose:
			var l = 1
			var maxLength:int = ceil(log(lines.size())/log(10))
			for i in lines:
				print(" ".repeat(maxLength - String.num_int64(l).length()) + String.num_int64(l) + "> " + i)
				l += 1
	return ""
