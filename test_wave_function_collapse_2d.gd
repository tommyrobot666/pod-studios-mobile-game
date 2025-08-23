@tool
extends WaveFunctionCollapse2D

@export var generate:bool:
	set(x):
		clear_tiles(Vector2i(8,8))
		solve_all_tiles(Vector2i(3,3),-1)
		if get_child_count() > 0:
			get_child(0).queue_free()
		var sprite = Sprite2D.new()
		sprite.texture = ImageTexture.create_from_image(to_image())
		add_child(sprite)
