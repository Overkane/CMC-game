extends Node

const _BIOMES: Array[Biome] = [
	preload("res://resources/biomes/forest_biome.tres"),
	preload("res://resources/biomes/desert_biome.tres"),
	preload("res://resources/biomes/snow_biome.tres"),
]

@onready var _roadTileMapLayer: TileMapLayer = $RoadTileMapLayer


func _ready() -> void:
	_generateRoads()


func _generateRoads() -> void:
	var currentChunk := 0

	for biome in _BIOMES:
		var biomeTilePattern: TileMapPattern = _roadTileMapLayer.tile_set.get_pattern(biome.biomeType)

		for i in biome.numberOfChunks:
			currentChunk += 1
			var patternPosition := Vector2(currentChunk * _roadTileMapLayer.get_viewport_rect().size.x, 0)
			_roadTileMapLayer.set_pattern(_roadTileMapLayer.local_to_map(patternPosition), biomeTilePattern)
