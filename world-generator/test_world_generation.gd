extends WorldGeneration

@export var grass_feature_location:FeatureLocation
@export var max_camera_dist:float = 1000
var noise = create_noise(FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH,FastNoiseLite.FractalType.FRACTAL_FBM,0.005,3,0.5)
var grass_noise = create_noise(FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH,FastNoiseLite.FractalType.FRACTAL_FBM,0.005,3,0.5)

func _ready() -> void:
	create_mesh(2,200)
	
	add_chunk_generator(ChunkGeneratorsEntry.new(grass_generator,
	[preload("res://world-generator/test_grass.tscn"),preload("res://world-generator/test_taller_grass.tscn")],
	grass_feature_location))
	
	
	pre_generate_chunks(-1,-1,1,1)
	move_to_camera()

func _process(delta: float) -> void:
	var camera_pos = get_tree().root.get_camera_3d().global_position
	if (global_position-camera_pos).length_squared() > max_camera_dist:
		move_to_camera()

func get_mesh_heights_at(chunks:Rect2i,detail:int) -> PackedFloat32Array:
	var heights = PackedFloat32Array()
	noise.seed = seed
	var segment_len:Vector2 = chunks.size * CHUNK_SIZE/detail
	var offset:Vector2 = chunks.position*CHUNK_SIZE
	for row in range(detail):
		for column in range(detail):
			var pos = Vector2(row,column)*segment_len + offset
			var height = noise.get_noise_2dv(pos) * 100
			heights.append(height)
	return heights

func get_mesh_colors_at(heights:PackedFloat32Array,chunks:Rect2i,detail:int) -> PackedColorArray:
	var colors = PackedColorArray()
	for i in range(heights.size()):
		var height = heights[i]
		if height > 0:
			if height > 20:
				colors.append(Color.WHITE)
			else:
				colors.append(Color.DIM_GRAY)
		else:
			if height < -20:
				colors.append(Color.BLUE)
			else:
				colors.append(Color.GREEN)
	return colors

func grass_generator(seed:int,chunk_pos:Vector2i,get_mesh_height_at:Callable) -> Array[ChunkGeneratorPlacement]:
	var random = RandomNumberGenerator.new()
	var placements:Array[ChunkGeneratorPlacement] = []
	random.seed = seed
	grass_noise.seed = seed + 123
	var grass_distance = 15
	for row in range(int(CHUNK_SIZE/grass_distance)):
		for column in range(int(CHUNK_SIZE/grass_distance)):
			var pos = Vector2(row*grass_distance,column*grass_distance)
			var global_pos = pos + chunk_pos*CHUNK_SIZE
			var value = grass_noise.get_noise_2dv(global_pos)
			var height = get_mesh_height_at.call(pos)
			if value > 0.2 and value < 0.8 and height < 0:
				placements.append(ChunkGeneratorPlacement.new(Vector3(pos.x,height,pos.y),\
				1 if random.randf() > 0.5 else 0))
	return placements
