extends Node
class_name WaveFunctionCollapse2D

var tiles:Array[int] # last bit 1 means "filled", for others 1 means "not that state"
@export var rules:Array[TileRuleset] # rules is also tile types
var width:int
var random:RandomNumberGenerator

# false means constraints satisfied
func solve_rule(tile_pos:Vector2i,rule_idx:int) -> bool:
	for tile in get_nearby_tiles(tile_pos):
		if tile & (2 ** rules.size()): # if tile is complete
			return ~tile & rules[rule_idx].nonadjacent # any matching pair of ones means that it can't be adjacent
	return false

func solve_tile(tile_pos:Vector2i) -> void:
	var tile:int = tiles[point_to_index(tile_pos)]
	for i in range(rules.size()):
		if ~tile & (2 ** i): # is a possible state
			if solve_rule(tile_pos,i):
				tile += 2 ** i # add state to "not that state" list
			if tile & (~tile)-1: # only one bit is 0
				tile += (2 ** rules.size())

func get_random_state(tile:int) -> int:
	var possible_states:Array[int] = []
	for i in range(rules.size()):
		if ~tile & (2 ** i): # is a possible state
			possible_states.append(i)
	
	var chossen_state:int
	var total:float = 0
	for rule_idx in possible_states:
		total += rules[rule_idx].weight
	var value:float = random.randf_range(0,total)
	total = 0
	for rule_idx in possible_states:
		total += rules[rule_idx].weight
		if total > value:
			chossen_state = rule_idx
	
	return (2 ** chossen_state) + (2 ** rules.size())

func solve_all_tiles(start_pos:Vector2i,first_state:int) -> void:
	var stack:Array[Vector2i] = get_nearby_tiles_pos(start_pos)
	if first_state < 0:
		var idx = point_to_index(start_pos)
		tiles[idx] = get_random_state(tiles[idx])
	else:
		tiles[point_to_index(start_pos)] = (2 ** first_state) + (2 ** rules.size())
	while stack.size() > 0:
		pass

func point_to_index(point:Vector2i) -> int:
	return point.x + point.y*width

func get_nearby_tiles(tile_pos:Vector2i) -> Array[int]:
	var output:Array[int] = []
	for dir in [Vector2i.UP,Vector2i.LEFT,Vector2i.DOWN,Vector2i.LEFT]:
		var point = tile_pos + dir
		var pos = point_to_index(point)
		if tiles.size() > pos and point.x > 0 and point.y > 0:
			output.append(tiles[pos])
		else:
			output.append(0)
	return output

func get_nearby_tiles_pos(tile_pos:Vector2i) -> Array[Vector2i]:
	var output:Array[Vector2i] = []
	for dir in [Vector2i.UP,Vector2i.LEFT,Vector2i.DOWN,Vector2i.LEFT]:
		var point = tile_pos + dir
		if is_point_in_tiles(point):
			output.append(point)
	return output

func is_point_in_tiles(tile_pos:Vector2i):
	var idx = point_to_index(tile_pos)
	return tiles.size() > idx and not (tile_pos.x < 0 and tile_pos.y < 0)

func clear_tiles(new_size:Vector2i) -> void:
	tiles.clear()
	width = new_size.x
	for __ in range(new_size.x*new_size.y):
		tiles.append(0)

func get_filled_tiles(tile_poses:Array[Vector2i]) -> Array[Vector2i]:
	return tile_poses.filter(func(x): x & 2 ** rules.size())

func get_filled_tile_value(tile:int) -> int:
	return log(tile-(2 ** rules.size()))/log(2)

func to_image() -> Image:
	var pixels:PackedColorArray = PackedColorArray()
	for __ in range(tiles.size()):
		pixels.append(Color.BLACK)
	
	var all_tile_pos:Array[Vector2i] = []
	for i in range(width):
		for j in range(tiles.size()/width):
			all_tile_pos.append(Vector2i(i,j))
	for tile_pos in get_filled_tiles(all_tile_pos):
		var idx = point_to_index(tile_pos)
		pixels[idx] = rules[get_filled_tile_value(tiles[idx])].debug_color
	
	return Image.create_from_data(width,tiles.size()/width,false,Image.FORMAT_RGBF,pixels.to_byte_array())
