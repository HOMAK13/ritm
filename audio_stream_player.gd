extends AudioStreamPlayer

func load_music(path: String):
	stream = AudioStreamMP3.load_from_file(path);
	play();

func update_volume(volume: float):
	volume_db = linear_to_db(volume)
