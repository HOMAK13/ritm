extends Node3D

var Player

func _process(delta: float) -> void:
	get_child(0).position.x = Player.position.x;
