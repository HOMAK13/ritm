extends Node2D

@onready var background: Sprite2D = get_child(0)
@onready var text = get_child(1)
@onready var charecter = get_child(2);
var background_width
var background_height

func _ready() -> void:
	get_viewport().connect("size_changed", _on_viewport_resize)
	background_width = background.texture.get_width()
	background_height = background.texture.get_height()
	_on_viewport_resize()
	
func _on_viewport_resize():
	var window = get_window().size
	background.scale.x = float(window.x) / float(background_width)
	background.scale.y = float(window.y)/5 / float(background_height)
	background.position.x = float(window.x) / float(background_width) * background_width / 2
	background.position.y =  float(window.y) - window.y / 5.0 /2
	background.z_index = 2
	text.label_settings.font_size = float(window.y)/5/4;
	if charecter.texture:
		charecter.scale.x = float(window.y)/5 / float(charecter.texture.get_width())
		charecter.scale.y = float(window.y)/5 / float(charecter.texture.get_height())
		charecter.position.x = charecter.scale.x * float(charecter.texture.get_width())/2
		charecter.position.y =  float(window.y) - (charecter.scale.y *  float(charecter.texture.get_width()))/2
	text.position.x = (charecter.scale.x * float(charecter.texture.get_width())) if charecter.texture else 0
	text.position.y =  float(window.y) - window.y / 5.0
	text.size.x = float(window.x) - ((charecter.scale.x * float(charecter.texture.get_width())) if charecter.texture else 0)
	text.size.y = window.y/5
	text.z_index = 3
	charecter.z_index = 5
func set_text_and_image(new_text, image = null):
	get_child(1).text = new_text
	if image:
		get_child(2).texture = ImageTexture.create_from_image(image)
	
func delete():
	queue_free()
