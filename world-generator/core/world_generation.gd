extends MeshInstance3D
class_name WorldGeneration
#to use this class, extend it and...
#override _get_mesh_height_at,_get_mesh_color_at
#add entries to chunk_generators

const CHUNK_SIZE = 500
@export_group("debug")
@export var noise = FastNoiseLite.new()

var seed = 0
var generated_chunks = []
var chunk_generators:Array[ChunkGeneratorsEntry]

func _ready() -> void:
	pre_generate_chunks(-1,-1,1,1)
	create_mesh(100,200)
	material_override = preload("res://world-generator/core/new_standard_material_3d.tres")

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
	for chunk_generator in chunk_generators:
		var chunk_node = create_chunk_node(x,y,chunk_generator.feature_location)
		var placements:Array[ChunkGeneratorPlacement] = chunk_generator.generator.call(seed,Vector2i(x,y))
		for placement in placements:
			var new_instance = chunk_generator.instance_scenes[placement.variant].instantiate()
			new_instance.position = placement.position
			chunk_node.add_child(new_instance)
	
	generated_chunks.append(Vector2(x,y))

func create_mesh(size:int,detail:int):
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
			verts.append(Vector3(segment_len*row - segment_len*row/2,0,segment_len*column - segment_len*column/2))
			colors.append(Color.WHITE)
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

func move_to_camera():
	var cam:Camera3D = get_tree().root.get_camera_3d()
	global_position = cam.global_position
	global_position.y = 0
	update_mesh()

func update_mesh():
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(mesh,0)
	for i in range(data_tool.get_vertex_count()):
		var vertex:Vector3 = data_tool.get_vertex(i)
		var pos = Vector2(position.x + vertex.x, position.y + vertex.y)
		var chunk_pos = Vector2i(pos.floor()/CHUNK_SIZE)
		var pos_in_chunk = Vector2(fmod(pos.x,CHUNK_SIZE),fmod(pos.y,CHUNK_SIZE))
		vertex.y = _get_mesh_height_at(chunk_pos,pos_in_chunk)
		data_tool.set_vertex_color(i,_get_mesh_color_at(vertex.y,chunk_pos,pos_in_chunk))
		data_tool.set_vertex(i,vertex)
	(mesh as ArrayMesh).clear_surfaces()
	data_tool.commit_to_surface(mesh,0)

func _get_mesh_height_at(chunk_pos:Vector2i,pos_in_chunk:Vector2) -> float:
	return 0

func _get_mesh_color_at(height:float,chunk_pos:Vector2i,pos_in_chunk:Vector2) -> Color:
	return Color.WHITE
