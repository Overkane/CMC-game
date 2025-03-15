extends Node

const _INITIAL_PATH_OFFSET := 200.0
const _END_PATH_OFFSET := 150.0
const _MINIMAL_DISTANCE_BETWEEN_BIOME_ENTITIES := 100.0
const _ENEMY_SCENE: PackedScene = preload("res://scenes/interactibles/enemy/enemy.tscn")
const _BONUS_SCENE: PackedScene = preload("res://scenes/interactibles/bonus/bonus.tscn")
const _OBSTACLE_SCENE: PackedScene = preload("res://scenes/interactibles/obstacle/obstacle.tscn")
const _BIOMES: Array[Biome] = [
	preload("res://resources/biomes/forest_biome.tres"),
	preload("res://resources/biomes/desert_biome.tres"),
	preload("res://resources/biomes/snow_biome.tres"),
]

var isIntro := true
var isGameStarted := false
var canRestartGame := false

@onready var _roadTileMapLayer: TileMapLayer = $RoadTileMapLayer


func _ready() -> void:
	%Player.died.connect(_onPlayer_died)

	GameConstants.player = %Player
	GameConstants.player.isMovementDisabled = true
	GameConstants.player.camera.enabled = false
	_generateBiomes()

	await $AnimationPlayer.animation_finished
	isIntro = false
	GameConstants.player.camera.enabled = true
	$IntroCamera2D.enabled = false
	%StartGameHintText.show()

func _input(event: InputEvent) -> void:
	if not isIntro and not isGameStarted and event is InputEventKey:
		isGameStarted = true
		%StartGameHintText.hide()
		GameConstants.player.isMovementDisabled = false
		GameConstants.player.changeAnimation("walk")
	elif canRestartGame and event is InputEventKey:
		canRestartGame = false
		%RestartGameHintText.hide()
		$AnimationPlayer.play("restart_transition")
		await $AnimationPlayer.animation_finished
		get_tree().reload_current_scene()


func _generateBiomes() -> void:
	var horizontalSizePerChunk := _roadTileMapLayer.get_viewport_rect().size.x
	var biomeDistanceShift := 0

	for biome in _BIOMES: # Biome shift X
		# Tile generation
		var biomeTilePattern: TileMapPattern = _roadTileMapLayer.tile_set.get_pattern(biome.biomeType)

		for i in biome.numberOfChunks:
			var patternPosition := Vector2(i * horizontalSizePerChunk + biomeDistanceShift, 0)
			_roadTileMapLayer.set_pattern(_roadTileMapLayer.local_to_map(patternPosition), biomeTilePattern)

		# Interactibles generation
		var fullBiomeDistance := horizontalSizePerChunk * biome.numberOfChunks
		for i in GameConstants.NUMBER_OF_PATHES:
			var generatedBiome: Array[BiomeEntity] = biome.generateBiome()

			var addOffset := true # TODO, offset should be only for the first biome
			var biomeEntityPosition := Vector2(biomeDistanceShift, GameConstants.FIRST_PATH_Y_COORD + i * GameConstants.DISTANCE_BETWEEN_PATHES)
			var biomeDistanceToSpawnEntities := fullBiomeDistance - _END_PATH_OFFSET

			if addOffset:
				biomeDistanceToSpawnEntities -= _INITIAL_PATH_OFFSET
				biomeEntityPosition.x += _INITIAL_PATH_OFFSET
				addOffset = false

			var distanceForOneEntity := biomeDistanceToSpawnEntities / generatedBiome.size()
			if distanceForOneEntity < _MINIMAL_DISTANCE_BETWEEN_BIOME_ENTITIES:
				push_error("Distance for 1 entity is less than minimal distance.")

			var distanceRemainder := 0.0
			for biomeEntity in generatedBiome:
				var positionChange := randf_range(_MINIMAL_DISTANCE_BETWEEN_BIOME_ENTITIES, distanceForOneEntity + distanceRemainder)
				biomeEntityPosition.x += positionChange

				var biomeEntityObject = _ENEMY_SCENE.instantiate()
				if biomeEntity is BiomeBonus:
					biomeEntityObject = _BONUS_SCENE.instantiate()
				elif biomeEntity is BiomeObstacle:
					biomeEntityObject = _OBSTACLE_SCENE.instantiate()
				biomeEntityObject.setup(biomeEntity, biomeEntityPosition)
				add_child(biomeEntityObject)

				distanceRemainder = distanceForOneEntity + distanceRemainder - positionChange

			# Spawn boss
			var bossPosition := Vector2(fullBiomeDistance + biomeDistanceShift, biomeEntityPosition.y)
			var biomeEntityObject := _ENEMY_SCENE.instantiate()
			biomeEntityObject.setup(biome.boss, bossPosition)
			add_child(biomeEntityObject)

		biomeDistanceShift += fullBiomeDistance


func _onPlayer_died() -> void:
	%RestartGameHintText.show()
	canRestartGame = true
