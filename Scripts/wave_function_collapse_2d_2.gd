extends WaveFunctionCollapse2D2

func _ready() -> void:
	set_up(Vector2i(5,10),146)
	randomize()
	solve_all_tiles(Vector2i(2,0),1)
	$"../GUI/Control/TextureRect".texture = ImageTexture.create_from_image(to_image())
