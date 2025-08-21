extends WorldGeneration

@export var max_camera_dist:float = 100000000:
	set(x):
		max_camera_dist = x*x
var noise = create_noise(FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH,FastNoiseLite.FractalType.FRACTAL_FBM,0.005,3,0.5)

func _ready() -> void:
	pre_generate_chunks(-1,-1,1,1)
	create_mesh(2,200)
	move_to_camera()
	update_mesh()

func _process(delta: float) -> void:
	var camera_pos = get_tree().root.get_camera_3d().global_position
	if (Vector2(camera_pos.x,camera_pos.z) - Vector2(global_position.x,global_position.z)).length_squared() > max_camera_dist:
		move_to_camera()

func get_mesh_heights_at(chunks:Rect2i,detail:int) -> PackedFloat32Array:
	var heights = PackedFloat32Array()
	#heights.resize(detail*detail)
	noise.seed = seed
	var segment_len:float = CHUNK_SIZE/detail
	var offset:Vector2 = chunks.position*CHUNK_SIZE
	for row in range(detail):
		for column in range(detail):
			var pos = Vector2(row,column)*segment_len + offset
			var height = noise.get_noise_2dv(pos) * 100
			heights.append(height)
	return heights

func get_mesh_colors_at(heights:PackedFloat32Array,chunks:Rect2i,detail:int) -> PackedColorArray:
	var colors = PackedColorArray()
	#colors.resize(detail*detail)
	for i in range(heights.size()):
		var height = heights[i]
		if height > 0:
			colors.append(Color.RED)
		else:
			colors.append(Color.BLUE)
	return colors
