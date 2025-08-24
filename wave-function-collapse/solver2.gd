extends Node
class_name WaveFunctionCollapse2D2

signal solve_all_tiles_step

var tiles:Array[Tile] # last bit 1 means "filled", for others 1 means "not that state"
@export var rules:Array[TileRuleset] # rules is also tile types
var width:int
var random:RandomNumberGenerator = RandomNumberGenerator.new()
var total_rules_weights:float = 0
var rules_chances:Array[float] = []

func _init():
	random.randomize()

# true means constraints satisfied
func solve_rule(tile_pos:Vector2i,rule_idx:int) -> bool:
	for tile in get_nearby_tiles(tile_pos):
		if tile.filled: # if tile is complete
			# (this evals as an int that gets converted to bool)
			# removind the not made it work, idk why
			return ((1<<tile.value) & rules[rule_idx].adjacent) # if tile not in adjacent, then can't be next to
	return true

# true means something changed
func solve_tile(tile_pos:Vector2i) -> bool:
	var something_changed:bool = false
	var tile:Tile = tiles[point_to_index(tile_pos)]
	for i in range(rules.size()):
		if tile.possible_states.has(i): # is a possible state
			if not solve_rule(tile_pos,i):
				tile.possible_states.erase(i) # remove from possible_states
				something_changed = true
			if tile.possible_states.size() == 1: # only one possible_states
				tile.filled = true
				tile.value = tile.possible_states[0]
	return something_changed

func get_random_state(tile:Tile) -> Tile:
	var chossen_state:int
	var value:float = random.randf_range(0,total_rules_weights)
	var total:float = 0
	for rule_idx in tile.possible_states:
		total += rules[rule_idx].weight
		if total > value:
			chossen_state = rule_idx
			break
	return filled_tile_value_for(chossen_state)

func solve_all_tiles(start_pos:Vector2i,first_state:int) -> void:
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
			for pos in get_nearby_tiles_pos(tile_pos):
				if not stack.has(pos):
					stack.append(pos)
		stack = get_unfilled_tiles(stack)
		
		if not something_changed and stack.size() > 0:
			var entropys:Array[float] = []
			for tile_pos in stack:
				var entropy:float = 0
				var tile = tiles[point_to_index(tile_pos)]
				for rule_idx in tile.possible_states:
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
			for pos in get_nearby_tiles_pos(stack[min_entropy_idx]):
				if not stack.has(pos):
					stack.append(pos)
		
		something_changed = false
		solve_all_tiles_step.emit()

func point_to_index(point:Vector2i) -> int:
	return point.x + point.y*width

func get_nearby_tiles(tile_pos:Vector2i) -> Array[Tile]:
	var output:Array[Tile] = []
	for dir in [Vector2i.UP,Vector2i.LEFT,Vector2i.DOWN,Vector2i.RIGHT]:
		var point = tile_pos + dir
		var pos = point_to_index(point)
		if tiles.size() > pos and point.x >= 0 and point.y >= 0:
			output.append(tiles[pos])
		else:
			output.append(Tile.new())
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
		var new_tile = Tile.new()
		for i in range(rules.size()):
			new_tile.possible_states.append(i)
		tiles.append(new_tile)

func get_filled_tiles(tile_poses:Array[Vector2i]) -> Array[Vector2i]:
	var why_isnt_this_function_working:Array[Vector2i]
	
	for idc in tile_poses:
		var tile = tiles[point_to_index(idc)]
		if tile.filled:
			why_isnt_this_function_working.append(idc)
	
	return why_isnt_this_function_working

func get_unfilled_tiles(tile_poses:Array[Vector2i]) -> Array[Vector2i]:
	var why_isnt_this_function_working:Array[Vector2i]
	
	for idc in tile_poses:
		var tile = tiles[point_to_index(idc)]
		if not tile.filled:
			why_isnt_this_function_working.append(idc)
	
	return why_isnt_this_function_working

func get_filled_tile_value(tile:Tile) -> int:
	return tile.value

func filled_tile_value_for(rule_idx:int):
	var tile = Tile.new()
	tile.filled = true
	tile.value = rule_idx
	tile.possible_states.append(rule_idx)
	return tile

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

func calculate_rules_chances() -> void:
	total_rules_weights = 0
	rules_chances = []
	for rule_idx in range(rules.size()):
		total_rules_weights += rules[rule_idx].weight
	for rule_idx in range(rules.size()):
		rules_chances.append(rules[rule_idx].weight/total_rules_weights)

func set_up(new_size:Vector2i,seed:int) -> void:
	random.seed = seed
	calculate_rules_chances()
	clear_tiles(new_size)
