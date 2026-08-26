extends TextureButton

var running:bool = false:
	set(x):
		running = x
		OS.low_processor_usage_mode = !x
var asmCompiler:Assembly
var code:String = ""
var time:float = 1.0
var time2:float = 1.0

var ports:Array[Port]

var testing:bool = false

func _ready() -> void:
	ports = [null, GPU.new(%Port1), null, null, null, null, null, null]
	for i in OS.get_cmdline_args():
		if i.begins_with("-s"):
			testing = true
		if i.ends_with(".bpu"):
			%Edit.text = FileAccess.get_file_as_string(i)
			code = %Edit.text
		if i.ends_with(".bpux"):
			asmCompiler = Assembly.create(code, ports)
			asmCompiler.cpu = CPU.new(FileAccess.get_file_as_bytes(i))
			asmCompiler.cpu.bind(ports)
			%Port1.visible = true
			running = true
			return
	%Edit.syntax_highlighter = AssemblyHighligher.new(%Edit)
	asmCompiler = Assembly.create(code, ports)

func _pressed() -> void:
	running = !running
	if running:
		%Port1.visible = true
		code = %Edit.text
		asmCompiler = Assembly.create(code, ports)
	else:
		%Port1.visible = false
		time = 1.0
		%Edit.text = code
		asmCompiler = Assembly.new(code)

func _process(delta: float) -> void:
	if testing:
		var timer:int = Time.get_ticks_msec()
		asmCompiler.cpu.exec(1_000_000)
		print("Clock Speed: ", 1_000_000_000_000 / (Time.get_ticks_usec() - timer), " Hz")
		testing = false
		return
	
	if Input.is_action_just_pressed("save"):
			%FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			%FileDialog.show()
			await %FileDialog.file_selected
			var file = FileAccess.open(%FileDialog.current_path,FileAccess.WRITE)
			if %FileDialog.current_path.ends_with(".bpux"):
				file.store_buffer(Assembly.truncate(asmCompiler.cpu.binary))
			else:
				file.store_string(code)
			file.close()
	
	if Input.is_action_just_pressed("open"):
			%FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			%FileDialog.show()
			await %FileDialog.file_selected
			if %FileDialog.current_path.ends_with(".bpux"):
				asmCompiler.cpu = CPU.new(FileAccess.get_file_as_bytes(%FileDialog.current_path))
				asmCompiler.cpu.bind(ports)
				%Port1.visible = true
				running = true
			%Edit.text = FileAccess.get_file_as_string(%FileDialog.current_path)
	
	if running:
		time += delta
		asmCompiler.cpu.exec(100)
			
		if time > 0.2:
			if Input.is_key_pressed(KEY_ALT):
				if %Edit.text != asmCompiler.code:
					%Edit.text = asmCompiler.code
			else:
				%Edit.text = asmCompiler.to_string()
			time = 0.0
	else:
		time2 += delta
		if time2 > 1.0:
			asmCompiler = Assembly.new(%Edit.text)
			time2 = 0.0
			for relative:String in asmCompiler.labels.keys():
				if relative.begins_with("."):
					%Edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, relative, relative.replace(".", ""), AssemblyHighligher.RELATIVE)
				else:
					%Edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, relative, relative.replace(".", ""), AssemblyHighligher.PRE_ARG)
			for op in AssemblyHighligher.OPERATIONS:
				%Edit.add_code_completion_option(CodeEdit.KIND_FUNCTION, op, op, AssemblyHighligher.OP)
			%Edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "#removeBlank", "removeBlank", AssemblyHighligher.PREPROCESSOR)
			var dir:DirAccess = DirAccess.open("res://Lang-ASM/Packages/")
			for i in dir.get_files():
				%Edit.add_code_completion_option(CodeEdit.KIND_CONSTANT, "#import " + i.replace(".bpu", ""), "import " + i.replace(".bpu", ""), AssemblyHighligher.PREPROCESSOR)
			%Edit.update_code_completion_options(true)
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://Start/Start.tscn")
	if Input.is_action_just_pressed("Page 2"):
		get_tree().change_scene_to_file("res://Lang-QB/QB.tscn")
	
