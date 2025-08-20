extends Node
class_name GenerationLocation

@export var delete_offscreen = false

func _process(delta: float) -> void:
	if delete_offscreen:
		pass

func save_all_chunks():
	pass

func load_chunks(data):
	pass
