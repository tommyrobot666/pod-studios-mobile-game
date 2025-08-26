@tool
extends MeshInstance3D

@export_category("settings")
@export var height:float:
	set(x):
		height = x
		calculate_player_jump()
		draw_jump()
@export var start_time:float:
	set(x):
		start_time = x
		calculate_player_jump()
		draw_jump()
@export var end_time:float:
	set(x):
		end_time = x
		calculate_player_jump()
		draw_jump()
@export var min_height:float:
	set(x):
		min_height = x
		calculate_player_jump()
		draw_jump()
@export var clear:bool:
	set(x):
		mesh = ArrayMesh.new()
		calculate_player_jump()
		draw_jump()
@export_category("values")
@export var start_velocity:float
@export var start_gravity:float
@export var end_velocity:float
@export var end_gravity:float
@export var min_jump_time:float
@export_group("mesh_settings")
@export var mesh_detail:int = 1
@export var mesh_height:float = -1

func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()
	
	mesh = ArrayMesh.new()
	calculate_player_jump()
	draw_jump()

func draw_jump():
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	var colors = PackedColorArray()
	
	verts.append(Vector3.ZERO)
	for i:float in range(mesh_detail-1):
		verts.append(Vector3(start_time*(i/mesh_detail),y_at(start_time*(i/mesh_detail),start_velocity,start_gravity),0))
		verts.append(Vector3(start_time*(i/mesh_detail),y_at(start_time*(i/mesh_detail),start_velocity,start_gravity)+mesh_height,0))
	verts.append(Vector3(start_time,y_at(start_time,start_velocity,start_gravity),0))
	verts.append(Vector3(start_time,y_at(start_time,start_velocity,start_gravity)+mesh_height,0))
	for i:float in range(mesh_detail-1):
		verts.append(Vector3(start_time+(end_time*(i/mesh_detail)),y_at(end_time+end_time*(i/mesh_detail),end_velocity,end_gravity),0))
		verts.append(Vector3(start_time+(end_time*(i/mesh_detail)),y_at(end_time+end_time*(i/mesh_detail),end_velocity,end_gravity)+mesh_height,0))
	verts.append(Vector3(start_time+end_time,0,0))
	
	indices.append_array(range(4+(mesh_detail-1)*4))
	
	for __ in range(4+(mesh_detail-1)*4):
		uvs.append(Vector2.ZERO)
		normals.append(Vector3.BACK)
		colors.append(Color.AQUA)
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	surface_array[Mesh.ARRAY_COLOR] = colors
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, surface_array)

func y_at(t,velocity,gravity):
	return (gravity*t*t)/2+velocity*t 

func calculate_player_jump():
	start_velocity = (2*height)/(start_time)
	start_gravity = -(2*height)/(start_time*start_time)
	end_velocity = (2*height)/(end_time)
	end_gravity = -(2*height)/(end_time*end_time)
	min_jump_time = (-start_velocity + sqrt(start_velocity*start_velocity + 2*start_gravity*min_height)) / start_gravity
