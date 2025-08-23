extends Node
class_name WaveFunctionCollapse2D

var tiles:Array[int] # last bit 1 means "filled", for others 1 means "not that state"
@export var rules:Array[TileRuleset] # rules is also tile types
var width:int
var random:RandomNumberGenerator = RandomNumberGenerator.new()

func _init():
	random.randomize()

# false means constraints satisfied
func solve_rule(tile_pos:Vector2i,rule_idx:int) -> bool:
	for tile in get_nearby_tiles(tile_pos):
		if tile & (2 ** rules.size()): # if tile is complete
			return ~tile & rules[rule_idx].nonadjacent # any matching pair of ones means that it can't be adjacent
	return false

# true means something changed
func solve_tile(tile_pos:Vector2i) -> bool:
	var something_changed:bool = false
	var tile:int = tiles[point_to_index(tile_pos)]
	for i in range(rules.size()):
		if ~tile & (2 ** i): # is a possible state
			if solve_rule(tile_pos,i):
				tile += 2 ** i # add state to "not that state" list
				something_changed = true
			if tile & (~tile)-1: # only one bit is 0
				tile += (2 ** rules.size())
				something_changed = true
	tiles[point_to_index(tile_pos)] = tile
	return something_changed

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
			break
	
	return filled_tile_value_for(chossen_state)

func solve_all_tiles(start_pos:Vector2i,first_state:int) -> void:
	var total_rules_weights:float = 0
	var rules_chances:Array[float] = []
	for rule_idx in range(rules.size()):
		total_rules_weights += rules[rule_idx].weight
	for rule_idx in range(rules.size()):
		rules_chances.append(rules[rule_idx].weight/total_rules_weights)
	
	
	if first_state < 0:
		var idx = point_to_index(start_pos)
		tiles[idx] = get_random_state(tiles[idx])
	else:
		tiles[point_to_index(start_pos)] = filled_tile_value_for(first_state)
	
	
	var something_changed:bool
	var stack:Array[Vector2i] = get_nearby_tiles_pos(start_pos)
	while stack.size() > 0:
		for i in range(stack.size()):
			if solve_tile(stack[i]):
				something_changed = true
		
		for tile_pos in get_filled_tiles(stack):
			stack.append_array((get_nearby_tiles_pos(tile_pos)))
		stack = get_unfilled_tiles(stack)
		
		if not something_changed and stack.size() > 0:
			var entropys:Array[float] = []
			for tile_pos in stack:
				var entropy:float = 0
				var tile = tiles[point_to_index(tile_pos)]
				for rule_idx in range(rules.size()):
					if ~tile & (2 ** rule_idx): # is a possible state
						var chance = rules_chances[rule_idx]
						entropy -= chance*log(chance)
				entropys.append(entropy)
			var min_entropy:float = INF
			var min_entropy_idx:int = 0
			for i in range(stack.size()):
				var entropy:float = entropys[i]
				if entropy < min_entropy:
					min_entropy = entropy
					min_entropy_idx = i
			
			tiles[point_to_index(stack[min_entropy_idx])] = get_random_state(tiles[point_to_index(stack[min_entropy_idx])])
			stack.append_array(get_nearby_tiles_pos(stack[min_entropy_idx]))
		
		something_changed = false

func point_to_index(point:Vector2i) -> int:
	return point.x + point.y*width

func get_nearby_tiles(tile_pos:Vector2i) -> Array[int]:
	var output:Array[int] = []
	for dir in [Vector2i.UP,Vector2i.LEFT,Vector2i.DOWN,Vector2i.RIGHT]:
		var point = tile_pos + dir
		var pos = point_to_index(point)
		if tiles.size() > pos and point.x > 0 and point.y > 0:
			output.append(tiles[pos])
		else:
			output.append(0)
	return output

func get_nearby_tiles_pos(tile_pos:Vector2i) -> Array[Vector2i]:
	var output:Array[Vector2i] = []
	for dir in [Vector2i.UP,Vector2i.LEFT,Vector2i.DOWN,Vector2i.RIGHT]:
		var point = tile_pos + dir
		if is_point_in_tiles(point):
			output.append(point)
	return output

func is_point_in_tiles(tile_pos:Vector2i):
	var idx = point_to_index(tile_pos)
	return tiles.size() > idx and tile_pos.x >= 0 and tile_pos.y >= 0

func clear_tiles(new_size:Vector2i) -> void:
	tiles.clear()
	width = new_size.x
	for __ in range(new_size.x*new_size.y):
		tiles.append(0)

func get_filled_tiles(tile_poses:Array[Vector2i]) -> Array[Vector2i]:
	return tile_poses.filter(func(x): tiles[point_to_index(x)] & 2 ** rules.size())

func get_unfilled_tiles(tile_poses:Array[Vector2i]) -> Array[Vector2i]:
	return tile_poses.filter(func(x): (tiles[point_to_index(x)] & 2 ** rules.size()) == 0)

func get_filled_tile_value(tile:int) -> int:
	for i in range(rules.size()):
		if ~tile & (2 ** i):
			return i
	return 0

func filled_tile_value_for(rule_idx:int):
	return (~(2 ** rules.size()) - (2 ** rule_idx)) + (2 ** rules.size())

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
	
	return Image.create_from_data(width,tiles.size()/width,false,Image.FORMAT_RGBAF,pixels.to_byte_array())
