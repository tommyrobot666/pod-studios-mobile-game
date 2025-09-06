extends WaveFunctionCollapse2D2

func _ready() -> void:
	set_up(Vector2i(7,20),randi())
	solve_all_tiles(Vector2i(2,0),1)
	#solve_all_tiles(Vector2i(0,2),1)
	$"../GUI/Control/TextureRect".texture = ImageTexture.create_from_image(to_image())
