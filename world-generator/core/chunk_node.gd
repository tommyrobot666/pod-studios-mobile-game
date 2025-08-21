extends Node3D
class_name ChunkNode

var chunk_pos:Vector2i

func _process(delta: float) -> void:
	if (get_parent() as FeatureLocation).delete_offscreen:
		pass
