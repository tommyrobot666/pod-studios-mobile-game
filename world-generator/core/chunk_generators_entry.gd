extends RefCounted
class_name ChunkGeneratorsEntry

var generator:Callable #func(seed:int,chunk_pos:Vector2i,get_mesh_height_at:Callable) -> Array[ChunkGeneratorOutput]
var instance_scenes:Array[PackedScene] #different varients, like rotations or colors
var feature_location:FeatureLocation #the node that the generated chunks will be childs of

func _init(generator:Callable,instance_scenes:Array[PackedScene],feature_location:FeatureLocation) -> void:
	self.generator = generator
	self.instance_scenes = instance_scenes
	self.feature_location = feature_location
