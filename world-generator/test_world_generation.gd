extends WorldGeneration

@export var max_camera_dist:float = 1000:
	set(x):
		max_camera_dist = x*x
var noise = create_noise(FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH,FastNoiseLite.FractalType.FRACTAL_FBM,0.005,3,0.5)

func _ready() -> void:
	pre_generate_chunks(-1,-1,1,1)
	create_mesh(300,200)

func _process(delta: float) -> void:
	var camera_pos = get_tree().root.get_camera_3d().global_position
	if (Vector2(camera_pos.x,camera_pos.z) - Vector2(global_position.x,global_position.z)).length_squared() > max_camera_dist:
		move_to_camera()

func get_mesh_height_at(chunk_pos:Vector2i,pos_in_chunk:Vector2) -> float:
	noise.seed = seed
	var global_pos:Vector2 = CHUNK_SIZE*Vector2(chunk_pos) + pos_in_chunk
	return noise.get_noise_2dv(global_pos)

func get_mesh_color_at(height:float,chunk_pos:Vector2i,pos_in_chunk:Vector2) -> Color:
	if height > 0:
		return Color.RED
	else:
		return Color.BLUE
