extends Control

var menu1 = []
var menu_credit = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$ButtonStart.grab_focus()


	menu1 = [
		$ButtonStart,
		$ButtonOptions,
		$ButtonQuit,
		$ButtonCredits,
		$TittleText,
	]

	menu_credit = [
		$CreditsText,
		$ButtonCreditsBack,
	]

	$ButtonStart.pressed.connect(self.start_button)
	$ButtonCredits.pressed.connect(self.credits_button)
	$ButtonCreditsBack.pressed.connect(self.credits_back_button)
	remove_all()
	pass # Replace with function body.


func start_button():
	for i in get_children().size():
		get_children()[i].queue_free()
	get_tree().change_scene_to_packed(load('res://assets/Scenes/HighResDebugScene.tscn'))
	return

func credits_button():
	change_panel(menu1, menu_credit, menu_credit[1])
	return

func credits_back_button():
	change_panel(menu_credit, menu1, menu1[0])

func remove_all():
	var n : Array = get_children()
	for i in n.size():
		if n[i] != $TextureRect:
				remove_child(n[i])
	for i in menu1.size():
		add_child(menu1[i])
	menu1[0].grab_focus()


func change_panel(_hide : Array, _show : Array, focus_node : Node):
	for i in _hide.size():
		remove_child(_hide[i])
		pass

	for i in _show.size():
		add_child(_show[i])
		pass
	
	focus_node.grab_focus()
	return