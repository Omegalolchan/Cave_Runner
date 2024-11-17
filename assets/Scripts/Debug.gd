extends Control

var placeholder_text = "-"
var on = false
var draw_on = false
var last_command : String
@onready var external_script_node = $Node
@onready var player : Player = Global.player

func _ready():
	$Label.text = placeholder_text
	enable_disable_UI()
	return

func _process(_delta):
	if draw_on:
		queue_redraw()
	pass

func _input(event):
	if Input.is_action_just_pressed("debug"):
		on = !on
		enable_disable_UI()
	
	#if Input.is_action_just_pressed("Menu"):
	#	get_tree().change_scene_to_packed(load('res://assets/Scenes/Menu.tscn'))

	if !on:
		return
	
	var backspace = func():
		var d_text : String = $Label.text
		if d_text.is_empty():
			return
		d_text = d_text.erase(d_text.length()-1, 1)
		$Label.text = d_text
	
	if event is InputEventKey and event.is_pressed():
		var key_text = event.as_text()
		if key_text.length() <= 1:
			if $Label.text == placeholder_text: 
				$Label.text = ""
			key_text = key_text.to_lower()
			$Label.text += key_text
			return
		
		match key_text:
			'Backspace':
				backspace.call()
				return
			'Slash':
				$Label.text += "/"	
			'Ctrl+R':
				$Label.text = last_command
			'Ctrl+L':
				clear()
			'Space':
				$Label.text += " "
			'Enter':
				run_command($Label.text)
				last_command = $Label.text
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
			size = Vector2i(int(command_array[1]), int(command_array[2]))
			ResolutionHandler.window.size = size
		'reloadscene':
			get_tree().reload_current_scene()
		'draw':
			draw_on = !draw_on
		_:
			print("this commmand does not exist")
	return

func clear():
	$Label.text = placeholder_text
	return

func enable_disable_UI():
	if on:
		visible = true
		$Label.text = placeholder_text
	else:
		$Label.text = ""
		visible = false

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
