extends Node2D

var placeholder_text = "-"
var on = false
var draw_on = false
var last_command : String
var label_text
var default_font = ThemeDB.fallback_font
@onready var external_script_node = $Node
@onready var player : Player = Global.player

func _ready():
	label_text = placeholder_text
	enable_disable_UI()
	return

func _process(_delta):
	queue_redraw()

func _draw():
	if draw_on:
		draw_string(default_font, Vector2(0,32), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color.LIGHT_GREEN)
		draw_string(default_font, Vector2(0,DisplayServer.screen_get_size().y - 32),"Click to change position", HORIZONTAL_ALIGNMENT_LEFT, -1, 32)

func _input(event):
	if Input.is_action_just_pressed("debug"):
		on = !on
		enable_disable_UI()

	if !on:
		return

	if event is InputEventMouseButton and event.is_released():
		if event.button_index == MOUSE_BUTTON_LEFT:
			Global.player.position = Global.player.get_global_mouse_position()
		pass
	
	var backspace = func():
		var d_text : String = label_text
		if d_text.is_empty():
			return
		d_text = d_text.erase(d_text.length()-1, 1)
		label_text = d_text
	
	if event is InputEventKey and event.is_pressed():
		var key_text = event.as_text()

		if key_text.contains('Shift+') and key_text.length() == 7: # SHIFT+ANYLETTER length is 7
			if label_text == placeholder_text: 
				label_text = ""
			key_text = key_text.erase(0,6)			
			label_text += key_text
		elif key_text.length() == 1:
			if label_text == placeholder_text: 
				label_text = ""
			key_text = key_text.to_lower()
			label_text += key_text
			return
		
		match key_text:
			'Backspace':
				backspace.call()
				return
			'Slash':
				label_text += "/"	
			'Ctrl+R':
				label_text = last_command
			'Ctrl+L':
				clear()
			'Space':
				label_text += " "
			'Enter':
				run_command(label_text)
				last_command = label_text
				on = false
				enable_disable_UI()

func run_command(command_line : String):
	if command_line.is_empty():
		return
	var command_array = command_line.split(" ", false)
	match command_array[0]:
		'run':
			run_external_script()
		'res':
			var size = Vector2i(int(command_array[1]), int(command_array[2]))
			ResolutionHandler.window.size = size
		'reloadscene':
			Global.change_scene(Global._current_scene_file_name)
		'loadscene':
			var _str : String = command_line 
			_str = _str.erase(0, command_array[0].length() + 1)
			Global.change_scene(_str)
		'echo':
			var _str : String = command_line 
			_str = _str.erase(0, command_array[0].length() + 1)
			print(_str)
		'setcheckpoint':
			if Global.managers['checkpoint_manager'] != null:
				Global.managers['checkpoint_manager'].update_checkpoint(Global.player.position, 'debug')	
			else: 
				print('Not in a level')
		'help':
			print("commands: run //run external script")
			print("commands: res //change resolution -> res[space]x[space]y")
			print("commands: reloadscene //reloads the current main scene (not level)")
			print("commands: setscheckpoint //sets checkpoint")
		_:
			print("this commmand does not exist")
	return

func clear():
	label_text = placeholder_text
	return

func enable_disable_UI():
	if on:
		label_text = placeholder_text
		draw_on = true
	else:
		draw_on = false
		label_text = ""

func run_external_script():
	###################################################
	#external script needs to be one dir before res
	#name = debug_cr_script.gd
	#extends from node
	#and have run()
	####################################################

	var path = ProjectSettings.globalize_path('res://')
	var b = FileAccess.file_exists(path+'../debug_cr_script.gd')
	if !b:
		return
	
	var file = FileAccess.open(path+'../debug_cr_script.gd', FileAccess.READ)
	var ex_script = GDScript.new()
	ex_script.source_code = file.get_as_text()
	ex_script.reload()
	file.close()
	external_script_node.set_script(ex_script)
	external_script_node.run()
	external_script_node.set_script(null)

	return
