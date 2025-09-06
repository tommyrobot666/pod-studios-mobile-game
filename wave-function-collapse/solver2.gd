extends Node
class_name WaveFunctionCollapse2D2

signal solve_all_tiles_step
signal solve_all_tiles_done

var tiles:Array[Tile] # last bit 1 means "filled", for others 1 means "not that state"
@export var rules:Array[TileRuleset2] # rules is also tile types
var width:int
var random:RandomNumberGenerator = RandomNumberGenerator.new()
var rules_chances:Array[float] = []

# true means constraints satisfied
func solve_rule(tile_pos:Vector2i,rule_idx:int) -> bool:
	var rule = rules[rule_idx]
	# get_not_any_tiles filters out tiles that could be anything because those don't need to be checked
	# that's how I thought it would work, but idk why get_not_any_tiles makes it work
	for tile in get_not_any_tiles(h_get_nearby_tiles(tile_pos)):
		var has_any_common_states = false
		for state in tile.possible_states:
			if rule.h_adjacent.has(state):
				has_any_common_states = true
		if not has_any_common_states:
			return false
	# get_not_any_tiles filters out tiles that could be anything because those don't need to be checked
	# that's how I thought it would work, but idk why get_not_any_tiles makes it work
	for tile in get_not_any_tiles(v_get_nearby_tiles(tile_pos)):
		var has_any_common_states = false
		for state in tile.possible_states:
			if rule.v_adjacent.has(state):
				has_any_common_states = true
		if not has_any_common_states:
			return false
	return true

# true means something changed
func solve_tile(tile_pos:Vector2i) -> bool:
	var tile:Tile = tiles[point_to_index(tile_pos)]
	if tile.filled:
		return false
	
	var something_changed:bool = false
	for rule_idx in tile.possible_states:
		if rule_idx < 0:
			printerr("what? a tile can't be -1")
		if not solve_rule(tile_pos,rule_idx):
			tile.possible_states.erase(rule_idx) # remove from possible_states
			something_changed = true
		if tile.possible_states.size() == 1: # only one possible_states
			tile = filled_tile_value_for(tile.possible_states[0])
	if tile.possible_states.is_empty():
		tile = filled_tile_value_for(-1)
	return something_changed

func get_random_state(tile:Tile) -> Tile:
	# get's what to scale by so that when impossible states are removed, chances still add up to 1
	var total_possible_rules_chances:float = 0
	for rule_idx in tile.possible_states:
		total_possible_rules_chances += rules_chances[rule_idx]
	var chances_scale:float = 1/total_possible_rules_chances
	
	# the real random picker
	var chossen_state:int = -1
	var value:float = random.randf()
	var total:float = 0
	for rule_idx in tile.possible_states:
		total += rules_chances[rule_idx] * chances_scale
		if total > value:
			chossen_state = rule_idx
			break
	return filled_tile_value_for(chossen_state)

func solve_all_tiles(start_pos:Vector2i,first_state:int) -> void:
	# set first state
	if first_state < 0:
		var idx = point_to_index(start_pos)
		tiles[idx] = get_random_state(tiles[idx])
	else:
		tiles[point_to_index(start_pos)] = filled_tile_value_for(first_state)
	
	# solve other tiles
	var something_changed:bool
	var stack:Array[Vector2i] = get_nearby_tiles_pos(start_pos)
	while stack.size() > 0:
		# solve tiles
		for i in range(stack.size()):
			if solve_tile(stack[i]):
				something_changed = true
		
		# add adjacent tiles and remove solved tiles
		for tile_pos in get_filled_tiles(stack):
			for pos in get_nearby_tiles_pos(tile_pos):
				if not stack.has(pos):
					stack.append(pos)
		stack = get_unfilled_tiles(stack)
		
		# solve random tile if no tiles get solved
		if not something_changed and stack.size() > 0:
			# calculate entropys
			var entropys:Array[float] = []
			for tile_pos in stack:
				var entropy:float = 0
				var tile = tiles[point_to_index(tile_pos)]
				for rule_idx in tile.possible_states:
					var chance = rules_chances[rule_idx]
					entropy -= chance*log(chance)
				entropys.append(entropy)
			
			# select the one with the least entropy (idk why tho)
			var min_entropy:float = INF
			var min_entropy_idx:int = 0
			for i in range(stack.size()):
				var entropy:float = entropys[i]
				if entropy < min_entropy:
					min_entropy = entropy
					min_entropy_idx = i
			
			# select a value for the tile
			tiles[point_to_index(stack[min_entropy_idx])] = get_random_state(tiles[point_to_index(stack[min_entropy_idx])])
			# add adjacent tiles to the stack
			for pos in get_nearby_tiles_pos(stack[min_entropy_idx]):
				if not stack.has(pos):
					stack.append(pos)
		
		# shuffle stack to increase randomness (built-in function uses global random)
		#fisher_yates_shuffle(stack)
		something_changed = false
		solve_all_tiles_step.emit()
	solve_all_tiles_done.emit()

#func fisher_yates_shuffle(ls:Array) -> void:
	#var j:int = 0
	#for i in range(ls.size()):
		#j = random.randi_range(0,ls.size()-i)
		#
		## swap
		#var tmp = ls[i]
		#ls[i] = ls[j]
		#ls[j] = tmp

func point_to_index(point:Vector2i) -> int:
	return point.x + point.y*width

func get_nearby_tiles(tile_pos:Vector2i) -> Array[Tile]:
	var output:Array[Tile] = []
	for dir in [Vector2i.UP,Vector2i.LEFT,Vector2i.DOWN,Vector2i.RIGHT]:
		var point = tile_pos + dir
		var pos = point_to_index(point)
		if tiles.size() > pos and point.x >= 0 and point.y >= 0 and point.x < width:
			output.append(tiles[pos])
	return output

func v_get_nearby_tiles(tile_pos:Vector2i) -> Array[Tile]:
	var output:Array[Tile] = []
	for dir in [Vector2i.UP,Vector2i.DOWN]:
		var point = tile_pos + dir
		var pos = point_to_index(point)
		if tiles.size() > pos and point.x >= 0 and point.y >= 0 and point.x < width:
			output.append(tiles[pos])
	return output

func h_get_nearby_tiles(tile_pos:Vector2i) -> Array[Tile]:
	var output:Array[Tile] = []
	for dir in [Vector2i.LEFT,Vector2i.RIGHT]:
		var point = tile_pos + dir
		var pos = point_to_index(point)
		if tiles.size() > pos and point.x >= 0 and point.y >= 0 and point.x < width:
			output.append(tiles[pos])
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
	return tiles.size() > idx and tile_pos.x >= 0 and tile_pos.y >= 0 and tile_pos.x < width

func clear_tiles(new_size:Vector2i) -> void:
	tiles.clear()
	width = new_size.x
	for __ in range(new_size.x*new_size.y):
		var new_tile = Tile.new()
		for i in range(rules.size()):
			new_tile.possible_states.append(i)
		tiles.append(new_tile)

func get_filled_tiles(tile_poses:Array[Vector2i]) -> Array[Vector2i]:
	var out:Array[Vector2i]
	
	for i in tile_poses:
		var tile = tiles[point_to_index(i)]
		if tile.filled:
			out.append(i)
	
	return out

func get_unfilled_tiles(tile_poses:Array[Vector2i]) -> Array[Vector2i]:
	var out:Array[Vector2i]
	
	for i in tile_poses:
		var tile = tiles[point_to_index(i)]
		if not tile.filled:
			out.append(i)
	
	return out

func get_not_any_tiles(tiles:Array[Tile]) -> Array[Tile]:
	var out:Array[Tile]
	
	for tile in tiles:
		if tile.possible_states.size() != rules.size():
			out.append(tile)
	
	return out

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
		var tile = tiles[idx]
		if tile.value > -1:
			pixels[idx] = rules[tile.value].debug_color
		else:
			pixels[idx] = Color.DIM_GRAY
	
	return Image.create_from_data(width,tiles.size()/width,false,Image.FORMAT_RGBAF,pixels.to_byte_array())

func calculate_rules_chances() -> void:
	var total_rules_weights:float = 0
	rules_chances = []
	for rule_idx in range(rules.size()):
		total_rules_weights += rules[rule_idx].weight
	for rule_idx in range(rules.size()):
		rules_chances.append(rules[rule_idx].weight/total_rules_weights)

func set_up(new_size:Vector2i,seed:int) -> void:
	random.seed = seed
	calculate_rules_chances()
	clear_tiles(new_size)
