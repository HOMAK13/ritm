extends Button

@onready var fd = get_tree().root.get_child(0).get_child(2);

func _ready():
	pressed.connect(_open_file_dialog)
	
func _open_file_dialog():
	fd.visible = true;
