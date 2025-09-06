extends GridToPlacements

func _ready() -> void:
	# WARNING: awaiting in ready may not be good
	await $"../WaveFunctionCollapse2D2".ready
	get_tiles_from_wave_function_collapse($"../WaveFunctionCollapse2D2")
	# the only PlacementDir that will ever be implemented
	place_all_3dthings(PlacementDir.SAME_SIZE_CORNER)
