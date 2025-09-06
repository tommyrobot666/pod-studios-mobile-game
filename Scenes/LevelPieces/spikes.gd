extends Area3D

func _ready() -> void:
	body_entered.connect(entered)

func entered(body):
	if body is CharacterBody3D:
		get_tree().reload_current_scene()
