extends GridToPlacements

var not_placed = true

func _process(_delta: float) -> void:
	if not_placed:
		get_tiles_from_wave_function_collapse($"../WaveFunctionCollapse2D2")
		# the only PlacementDir that will ever be implemented
		place_all_3dthings(PlacementDir.SAME_SIZE_CORNER)
		not_placed = false
