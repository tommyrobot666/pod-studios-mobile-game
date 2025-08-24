extends GridToPlacements

func _ready() -> void:
	(get_child(0) as WaveFunctionCollapse2D2).clear_tiles(Vector2i(16,16))
	(get_child(0) as WaveFunctionCollapse2D2).solve_all_tiles(Vector2i(3,3),-1)
	get_tiles_from_wave_function_collapse((get_child(0) as WaveFunctionCollapse2D2))
	place_all_3dthings(PlacementDir.SAME_SIZE_CORNER)
	get_child(0).queue_free()
	$Camera3D.make_current()
