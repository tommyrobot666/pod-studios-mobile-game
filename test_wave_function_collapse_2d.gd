@tool
extends WaveFunctionCollapse2D2

@export var generate:bool:
	set(x):
		test()

func _ready() -> void:
	random.seed = 123
	test()
	#print(get_filled_tiles([Vector2i(3,3)]))
	#print(get_unfilled_tiles([Vector2i(3,3)]))

func test() -> void:
	clear_tiles(Vector2i(8,8))
	solve_all_tiles(Vector2i(3,3),-1)
	if get_child_count() > 0:
		get_child(0).queue_free()
	var sprite = Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(to_image())
	add_child(sprite)
