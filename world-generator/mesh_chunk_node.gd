extends MeshInstance3D
class_name MeshChunkNode

var pos:Vector2

func create_mesh(size:int,detail:int,heights:PackedFloat32Array):
	mesh = ArrayMesh.new()
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	var colors = PackedColorArray()
	
	var segment_len:float = size as float/detail
	for row in range(detail):
		for column in range(detail):
			verts.append(Vector3(segment_len*row,heights[verts.size()],segment_len*column))
			if heights[verts.size()-1] > 10:
				colors.append(Color.WHITE)
			elif heights[verts.size()-1] < -10:
				colors.append(Color.BLUE)
			else:
				colors.append(Color.GREEN)
			#normals.append(Vector3.UP)
			normals.append((verts[verts.size()-1] as Vector3).normalized())
			uvs.append(Vector2(row as float/detail,column as float/detail))
			
			if row < detail-2:
				var first_point = row*detail + column
				indices.append(first_point)
				indices.append(first_point+1)
				indices.append(first_point+detail)
				
				indices.append(first_point+1)
				indices.append(first_point+detail+1)
				indices.append(first_point+detail)
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	surface_array[Mesh.ARRAY_COLOR] = colors
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

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
