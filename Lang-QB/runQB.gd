extends TextureButton

var running:bool = false
var asmCompiler:Assembly
var code:String = ""
var time:float = 1.0
var time2:float = 1.0
var postproc:Dictionary
var undefined:PackedByteArray
var ports:Array[Port]

func _ready() -> void:
	for i in OS.get_cmdline_args():
		if i.ends_with(".qb"):
			%Edit.text = FileAccess.get_file_as_string(i)
			code = %Edit.text
	%Edit.syntax_highlighter = QBHighlighter.new(%Edit)
	ports = [null, GPU.new(%Port1), null, null, null, null, null, null]
	asmCompiler = CompilerQB.compile(code)

func _pressed() -> void:
	running = !running
	if running:
		code = %Edit.text
		asmCompiler = CompilerQB.compile(%Edit.text, ports)
		if !asmCompiler.error:
			%Port1.visible = true
	else:
		%Port1.visible = false
		time = 1.0
		%Edit.text = code
		asmCompiler = CompilerQB.compile(%Edit.text)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("save"):
			%FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			%FileDialog.show()
			await %FileDialog.file_selected
			var file = FileAccess.open(%FileDialog.current_path,FileAccess.WRITE)
			if %FileDialog.current_path.ends_with(".bpux"):
				asmCompiler = CompilerQB.compile(code)
				file.store_buffer(Assembly.truncate(asmCompiler.cpu.binary))
			elif %FileDialog.current_path.ends_with(".bpu"):
				file.store_string(asmCompiler.code)
			else:
				file.store_string(code)
			file.close()
	
	if Input.is_action_just_pressed("open"):
			%FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			%FileDialog.show()
			await %FileDialog.file_selected
			%Edit.text = FileAccess.get_file_as_string(%FileDialog.current_path)
	
	if running:
		asmCompiler.cpu.exec(60)
		time += delta
		
		if time > 0.1:
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
	
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://Start/Start.tscn")
	if Input.is_action_just_pressed("Page 1"):
		get_tree().change_scene_to_file("res://Lang-ASM/ASM.tscn")
