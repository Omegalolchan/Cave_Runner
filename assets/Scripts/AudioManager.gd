extends Node

@export var jump : AudioStreamPlayer
@export var walk : AudioStreamPlayer
@export var slide : AudioStreamPlayer

func _walk():
	jump.playing = false
	slide.playing = false
	if !walk.playing:
		walk.play()
	return

func _slide():
	jump.playing = false
	if !slide.playing: slide.play()
	walk.playing = false
	return

func _jump():
	if !jump.playing: jump.play()
	slide.playing = false
	walk.playing = false
	return

func stop_all():
	jump.playing = false
	slide.playing = false
	walk.playing = false
	
