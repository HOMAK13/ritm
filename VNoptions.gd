extends Node2D

var buttons = [ ]

@onready var root = get_parent()

func _ready() -> void:
	get_window().connect("size_changed", _on_window_resize)
	_create_choose_ui()
	pass

func _create_choose_ui():
	var window = get_window().size
	var i = -buttons.size() / 2.0;
	for item in buttons:
		print(item)
		var scene = Button.new()
		scene.text = item[3]
		scene.connect("pressed", _handle_button_press.bind(item[0], item[1], item[2]))
		add_child(scene)
		scene.size.x = window.x/2.0
		scene.size.y = window.y/4.0/buttons.size()
		scene.position.x = window.x/4
		scene.position.y = window.y/2 + scene.size.y*i
		i += 1.0
		
func _on_window_resize():
	var window = get_window().size
	var i = -buttons.size() / 2.0;
	for scene in get_children():
		scene.size.x = window.x/2.0
		scene.size.y = window.y/4.0/buttons.size()
		scene.position.x = window.x/4.0
		scene.position.y = window.y/2 + scene.size.y*i
		i += 1.0

func _handle_button_press(VAR, OPERATOR, VAL):
	if OPERATOR == "=":
		root.VARIABLES[VAR] = VAL
	elif OPERATOR == "+":
		root.VARIABLES[VAR] = int(VAL) + int(root.VARIABLES[VAR])
	elif OPERATOR == "-":
		root.VARIABLES[VAR] = int(root.VARIABLES[VAR]) - int(VAL)
	root.is_waiting_for_player = false
	root.is_option_window_open = false
	queue_free()
