extends MeshInstance3D
class_name MeshChunkNode

var pos:Vector2



func generate_noise(size:int,scaled:float,seed,octaves,frequency,gain,noise_type:FastNoiseLite.NoiseType,fractal_type:FastNoiseLite.FractalType,celluler_return_type:FastNoiseLite.CellularReturnType=0) -> PackedFloat32Array:
	var noise = FastNoiseLite.new()
	noise.offset = Vector3(pos.x*WorldGeneration.CHUNK_SIZE,0,pos.y*WorldGeneration.CHUNK_SIZE)
	noise.seed = seed
	noise.frequency = frequency
	noise.fractal_octaves = octaves
	noise.fractal_gain = gain
	noise.fractal_type = fractal_type
	noise.noise_type = noise_type
	if noise_type == FastNoiseLite.TYPE_CELLULAR:
		noise.cellular_return_type = celluler_return_type
	
	var heights = PackedFloat32Array()
	heights.resize(size*size)
	for row in range(size):
		for column in range(size):
			heights[row*size+column] = noise.get_noise_2d(row,column) * scaled
	
	return heights
