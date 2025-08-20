extends Node3D
class_name WorldGeneration

const CHUNK_SIZE = 500
const CHUNK_DETAIL = 1000
@export var PLANT_LOCATION:GenerationLocation = null
@export var MATERIAL_LOCATION:GenerationLocation = null

@export_group("debug")
@export var noise = FastNoiseLite.new()
@export var modulate_red = false
@export var skip_slow_generators = false

var seed = 0

var generated_chunks = []

func _ready() -> void:
	pre_generate_chunks(-1,-1,1,1)
	#pre_generate_chunks(-2,-2,2,2)
	#pre_generate_chunks(-5,-5,5,5,true)

#func _process(_delta: float) -> void:
	#var camera_rect = Rect2(get_viewport().get_camera_2d().global_position-get_viewport_rect().size/2,get_viewport_rect().size)
	#for pos in get_chunks_in_rect(camera_rect):
		#if not generated_chunks.has(pos):
			#generate_chunk(pos.x,pos.y,self.seed,true)

func pre_generate_chunks(x1,y1,x2,y2,placeholders=false):
	var pos = null
	for x in range(x1,x2+1):
		for y in range(y1,y2+1):
			pos = Vector2(x,y)
			if not generated_chunks.has(pos):
				generate_chunk(x,y,seed,placeholders)

#func get_chunks_in_rect(rect):
	#var stack = []
	#var chunks = []
	#stack.append(Vector2(floor(rect.position.x/CHUNK_SIZE),floor(rect.position.y/CHUNK_SIZE)))
	#var pos
	#var current_pos
	#while stack.size() > 0:
		#current_pos = stack[0]
		#for x in range(-1,2):
			#for y in range(-1,2):
				#pos = current_pos + Vector2(x,y)
				#if not (stack.has(pos) or chunks.has(pos)):
					#if Rect2(pos*Vector2(CHUNK_SIZE,CHUNK_SIZE),Vector2(CHUNK_SIZE,CHUNK_SIZE)).intersects(rect):
						#stack.append(pos)
		#chunks.append(current_pos)
		#stack.pop_front()
	#return chunks

func create_chunk_node(x:int,y:int,feature_location):
	var chunk_node = ChunkNode.new()
	chunk_node.name = str(x)+","+str(y)
	chunk_node.pos = Vector2(x,y)
	feature_location.add_child(chunk_node)
	return chunk_node

func create_mesh_chunk_node(x:int,y:int):
	var chunk_node = MeshChunkNode.new()
	chunk_node.name = str(x)+","+str(y)
	chunk_node.pos = Vector2(x,y)
	chunk_node.position = Vector3(x*CHUNK_SIZE,0,y*CHUNK_SIZE)
	add_child(chunk_node)
	return chunk_node

func generate_chunk(x,y,seed,placeholders):
	var mesh_chunk_node = create_mesh_chunk_node(x,y)
	mesh_chunk_node.create_mesh(CHUNK_SIZE,CHUNK_DETAIL,mesh_chunk_node.generate_noise(CHUNK_DETAIL,60,seed,2,0.001,0.5,FastNoiseLite.NoiseType.TYPE_PERLIN,FastNoiseLite.FractalType.FRACTAL_FBM))
	mesh_chunk_node.material_override = preload("res://world-generator/new_standard_material_3d.tres")
	
	generated_chunks.append(Vector2(x,y))


#func generate_with_noise(location,scene,size,x,y,seed,density,octaves,frequency,gain,noise_type,fractal_type,celluler_return_type):
	#var chunk_node = create_chunk_node(x,y,location)
	#var noise = FastNoiseLite.new()
	#noise.seed = seed
	#noise.frequency = frequency
	#noise.fractal_octaves = octaves
	#noise.fractal_gain = gain
	#noise.fractal_type = fractal_type
	#noise.noise_type = noise_type
	#if noise_type == FastNoiseLite.TYPE_CELLULAR:
		#noise.cellular_return_type = celluler_return_type
	#
	#var pos = null
	#var value = null
	#for px in range(0,CHUNK_SIZE,size.x):
		#for py in range(0,CHUNK_SIZE,size.y):
			#pos = Vector2(px+x*CHUNK_SIZE,py+y*CHUNK_SIZE)
			#value = noise.get_noise_2d(pos.x,pos.y)
			#if density < 0 and (value+1) < -density:
				#continue
			#elif density > 0 and (value+1) > density:
				#continue
			#var instance = scene.instantiate()
			#if modulate_red:
				#instance.modulate = Color(value+1,0,0)
			#instance.position = pos
			#chunk_node.add_child(instance)
#
#
#func gen_nav_reg(x,y):
	#var reg = NavigationRegion2D.new()
	#var poly = NavigationPolygon.new()
	#poly.add_outline([Vector2(x*CHUNK_SIZE,y*CHUNK_SIZE),Vector2(x*CHUNK_SIZE+CHUNK_SIZE,y*CHUNK_SIZE),Vector2(x*CHUNK_SIZE+CHUNK_SIZE,y*CHUNK_SIZE+CHUNK_SIZE),Vector2(x*CHUNK_SIZE,y*CHUNK_SIZE+CHUNK_SIZE)])
	#reg.navigation_polygon = poly
