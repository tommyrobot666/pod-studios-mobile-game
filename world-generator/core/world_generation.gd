extends MeshInstance3D
class_name WorldGeneration
#to use this class, extend it and...
#override get_mesh_heights_at,get_mesh_colors_at
#add entries to chunk_generators
#call create_mesh, pre_generate_chunks, and move_to_camera

const CHUNK_SIZE:float = 500
@export_group("debug")
@export var what_noise_looks_like = FastNoiseLite.new()

var seed = 0
var generated_chunks = []
var chunk_generators:Array[ChunkGeneratorsEntry]
var mesh_size_chunks:Vector2i
var position_as_chunk:Vector2i:
	get():
		return Vector2i(floori(position.x/CHUNK_SIZE),floori(position.z/CHUNK_SIZE))
var mesh_detail:int
var point_heights

func _ready() -> void:
	material_override = preload("res://world-generator/core/new_shader_material.tres")

func pre_generate_chunks(x1,y1,x2,y2):
	var pos = null
	for x in range(x1,x2+1):
		for y in range(y1,y2+1):
			pos = Vector2(x,y)
			if not generated_chunks.has(pos):
				generate_chunk(x,y,seed)

func create_chunk_node(x:int,y:int,feature_location:FeatureLocation):
	var chunk_node = ChunkNode.new()
	chunk_node.name = str(x)+","+str(y)
	chunk_node.chunk_pos = Vector2i(x,y)
	chunk_node.position = Vector3(x*CHUNK_SIZE,0,y*CHUNK_SIZE)
	feature_location.add_child(chunk_node)
	return chunk_node

func generate_chunk(x:int,y:int,seed:int):
	var heights_of_this_chunk = get_mesh_heights_at(Rect2i(Vector2i(x,y),Vector2.ONE),mesh_detail)
	var get_mesh_height_at:Callable = func(pos:Vector2): 
		var array_pos := Vector2i(
		floor(pos.x / CHUNK_SIZE * mesh_detail),
		floor(pos.y / CHUNK_SIZE * mesh_detail))
		return heights_of_this_chunk[array_pos.y + array_pos.x*mesh_detail]
	
	for chunk_generator in chunk_generators:
		var chunk_node = create_chunk_node(x,y,chunk_generator.feature_location)
		var placements:Array[ChunkGeneratorPlacement] = chunk_generator.generator.call(seed,Vector2i(x,y),\
		get_mesh_height_at)
		for placement in placements:
			var new_instance = chunk_generator.instance_scenes[placement.variant].instantiate()
			new_instance.position = placement.position
			chunk_node.add_child(new_instance)
	
	generated_chunks.append(Vector2(x,y))

func create_mesh(size_chunks:int,detail:int):
	mesh = ArrayMesh.new()
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	var colors = PackedColorArray()
	
	var segment_len:float = size_chunks as float/detail * CHUNK_SIZE
	for row in range(detail):
		for column in range(detail):
			verts.append(Vector3(segment_len*row,0,segment_len*column))
			colors.append(Color.WHITE)
			normals.append(Vector3.UP)
			uvs.append(Vector2(row as float/detail,column as float/detail))
			
			if row < detail-1 and column < detail-1:
				var first_point = row*detail + column
				indices.append(first_point)
				indices.append(first_point+detail)
				indices.append(first_point+detail+1)
				
				indices.append(first_point)
				indices.append(first_point+detail+1)
				indices.append(first_point+1)
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	surface_array[Mesh.ARRAY_COLOR] = colors
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	mesh_size_chunks = Vector2i(size_chunks,size_chunks)
	mesh_detail = detail

func move_to_camera():
	var cam:Camera3D = get_tree().root.get_camera_3d()
	global_position = ((cam.global_position/CHUNK_SIZE).floor() * CHUNK_SIZE) - (Vector3(mesh_size_chunks.x,0,mesh_size_chunks.y)*CHUNK_SIZE/2)
	global_position.y = 0
	update_mesh()

func update_mesh():
	point_heights = get_mesh_heights_at(Rect2i(position_as_chunk,mesh_size_chunks),mesh_detail)
	var heights_image = Image.create_from_data(mesh_detail,mesh_detail,false,Image.Format.FORMAT_RF,\
	point_heights.to_byte_array())
	var colors_image = Image.create_from_data(mesh_detail,mesh_detail,false,Image.Format.FORMAT_RGBAF,\
	get_mesh_colors_at(point_heights,Rect2i(position_as_chunk,mesh_size_chunks),mesh_detail).to_byte_array())
	
	material_override.set("shader_parameter/vertex_colors",ImageTexture.create_from_image(colors_image))
	material_override.set("shader_parameter/vertex_heights",ImageTexture.create_from_image(heights_image))
	material_override.set("shader_parameter/mesh_detail",mesh_detail)

static func create_noise(noise_type:FastNoiseLite.NoiseType,fractal_type:FastNoiseLite.FractalType,zoom,noise_on_noise,noise_on_noise_loss,celluler_return_type:FastNoiseLite.CellularReturnType=0) -> FastNoiseLite:
	var noise = FastNoiseLite.new()
	noise.frequency = zoom
	noise.fractal_octaves = noise_on_noise
	noise.fractal_gain = noise_on_noise_loss
	noise.fractal_type = fractal_type
	noise.noise_type = noise_type
	if noise_type == FastNoiseLite.TYPE_CELLULAR:
		noise.cellular_return_type = celluler_return_type
	return noise


func add_chunk_generator(entry:ChunkGeneratorsEntry):
	chunk_generators.append(entry)


func get_mesh_heights_at(chunks:Rect2i,detail:int) -> PackedFloat32Array:
	var heights = PackedFloat32Array()
	heights.resize(detail*detail)
	return heights

func get_mesh_colors_at(heights:PackedFloat32Array,chunks:Rect2i,detail:int) -> PackedColorArray:
	var colors = PackedColorArray()
	colors.resize(detail*detail)
	return colors
