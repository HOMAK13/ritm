extends AudioStreamPlayer

func load_music(path: String):
	stream = AudioStreamMP3.load_from_file(path);
	play();
