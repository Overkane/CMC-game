extends BiomeEntity
class_name BiomeObstacle

@export var damage := 10
# Traps are animated, but can provide only 1 texture, thus need to know how many frames in that texture.
@export var numberOfHorizontalFrames := 1
