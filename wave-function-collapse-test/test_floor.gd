extends MeshInstance3D

func _ready() -> void:
	position.y = get_parent().get_meta("slope",0) 
