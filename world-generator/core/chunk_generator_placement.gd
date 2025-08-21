extends RefCounted
class_name ChunkGeneratorPlacement

var position:Vector3 #position in chunk
var variant:int #varient index

func _init(position:Vector3,variant:int) -> void:
	self.position = position
	self.variant = variant
