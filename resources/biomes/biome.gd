extends Resource
class_name Biome

enum BiomeType { FOREST, DESERT, SNOW }

@export var biomeType: BiomeType
@export var numberOfChunks: int = 4
