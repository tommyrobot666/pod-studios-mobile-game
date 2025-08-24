@tool
extends WaveFunctionCollapse2D2

var sprite:Sprite2D

@export var generate:bool:
	set(x):
		test()

func _ready() -> void:
	solve_all_tiles_step.connect(show_step)
	if get_child_count() > 0:
		get_child(0).queue_free()
	sprite = Sprite2D.new()
	add_child(sprite)
	test()

func test() -> void:
	set_up(Vector2i(16,16),randi())
	random.randomize()
	solve_all_tiles(Vector2i(3,3),-1)
	sprite.texture = ImageTexture.create_from_image(to_image())

func show_step():
	sprite.texture = ImageTexture.create_from_image(to_image())
