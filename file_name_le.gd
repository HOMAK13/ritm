extends LineEdit

func _ready() -> void:
	text_submitted.connect(_on_change)
	
func _on_change(text):
	get_tree().root.get_child(0).project_name = text;
