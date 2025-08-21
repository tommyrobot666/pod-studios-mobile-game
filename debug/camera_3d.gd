extends Camera3D

func _process(delta: float) -> void:
	position += Vector3(Input.get_axis("ui_left","ui_right"),Input.get_axis("ui_home","ui_end"),Input.get_axis("ui_up","ui_down")) * 50 * delta
	rotate_x(Input.get_axis("ui_page_up","ui_page_down")*2*delta)
