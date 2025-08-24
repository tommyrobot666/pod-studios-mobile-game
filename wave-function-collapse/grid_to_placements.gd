extends Node3D
class_name GridToPlacements

@export var placements:Array[GridToPlacementsPlacement]

var tiles:Array[int] = []
var tiles_size:Vector2i

enum PlacementDir {
	CENTER,
	CORNER,
	SAME_SIZE_CORNER
}


func place_3dthing(placement:GridToPlacementsPlacement,at:Vector2) -> void:
	var new_node = placement.scene.instantiate()
	new_node.position = Vector3(at.x,0,at.y)
	add_child(new_node)

func place_all_3dthings(placement_dir:PlacementDir) -> void:
	var center_pos:int = tiles_size.x/2
	var total_offset:Vector2 = Vector2.ZERO
	var offset:Vector2
	match placement_dir:
		PlacementDir.SAME_SIZE_CORNER:
			offset = placements[0].size
	
	for i in range(tiles_size.x*tiles_size.y):
		var pos:Vector2i = index_to_point(i)
		var placement = placements[tiles[i]]
		match placement_dir:
			PlacementDir.SAME_SIZE_CORNER:
				place_3dthing(placement,total_offset)
				
				if pos.x+1 >= tiles_size.x:
					total_offset.x = 0
					total_offset.y += offset.y
				else:
					total_offset.x += offset.x



func point_to_index(point:Vector2i) -> int:
	return point.x + point.y*tiles_size.x

func index_to_point(idx:int) -> Vector2i:
	return Vector2i(idx%tiles_size.x,idx/tiles_size.x)

func is_point_in_tiles(tile_pos:Vector2i):
	var idx = point_to_index(tile_pos)
	return tiles.size() > idx and tile_pos.x >= 0 and tile_pos.y >= 0
