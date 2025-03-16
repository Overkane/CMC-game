extends Node2D

const _FINAL_BOSS_SHIFT := 250
const _INITIAL_PATH_OFFSET := 200.0
const _END_PATH_OFFSET := 150.0
const _MINIMAL_DISTANCE_BETWEEN_BIOME_ENTITIES := 100.0
const _ENEMY_SCENE: PackedScene = preload("res://scenes/interactibles/enemy/enemy.tscn")
const _BONUS_SCENE: PackedScene = preload("res://scenes/interactibles/bonus/bonus.tscn")
const _OBSTACLE_SCENE: PackedScene = preload("res://scenes/interactibles/obstacle/obstacle.tscn")
const _BIOMES: Array[Biome] = [
	preload("res://resources/biomes/forest_biome.tres"),
	preload("res://resources/biomes/savanna_biome.tres"),
	preload("res://resources/biomes/snow_biome.tres"),
	preload("res://resources/biomes/dragon_lair_biome.tres"),
]

var _isIntro := true
var _isGameStarted := false
var _canRestartGame := false
# Player shouldn't be able to see behind the final boss, since there can be no tiles generated.
var _playerRightCameraLimit := 0

@onready var _roadTileMapLayer: TileMapLayer = $RoadTileMapLayer


func _ready() -> void:
	%Player.died.connect(_onPlayer_died)
	EventBus.finalBossDefeated.connect(_onFinalBossDefeated)

	GameConstants.player = %Player
	GameConstants.player.isMovementDisabled = true
	GameConstants.player.camera.enabled = false
	_generateBiomes()

	await $AnimationPlayer.animation_finished
	_isIntro = false
	GameConstants.player.camera.enabled = true
	GameConstants.player.camera.limit_right = true
	$IntroCamera2D.enabled = false
	%StartGameHintText.show()

func _input(event: InputEvent) -> void:
	if not _isIntro and not _isGameStarted and event is InputEventKey:
		_isGameStarted = true
		%StartGameHintText.hide()
		GameConstants.player.isMovementDisabled = false
		GameConstants.player.changeAnimation("walk")
	elif _canRestartGame and event is InputEventKey:
		_canRestartGame = false
		%RestartGameHintText.hide()
		$AnimationPlayer.play("restart_transition")
		await $AnimationPlayer.animation_finished
		get_tree().reload_current_scene()


func _generateBiomes() -> void:
	var horizontalSizePerChunk := _roadTileMapLayer.get_viewport_rect().size.x
	var biomeDistanceShift := 0.0

	for biome in _BIOMES: # Biome shift X
		# Tile generation
		var biomeTilePattern: TileMapPattern = _roadTileMapLayer.tile_set.get_pattern(biome.biomeType)

		for i in biome.numberOfChunks:
			var patternPosition := Vector2(i * horizontalSizePerChunk + biomeDistanceShift, 0)
			_roadTileMapLayer.set_pattern(_roadTileMapLayer.local_to_map(patternPosition), biomeTilePattern)

			# Props generation
			var topPosition := patternPosition
			var topSize := Vector2(horizontalSizePerChunk, 65)
			var debugTopColorRect := ColorRect.new()
			debugTopColorRect.position = topPosition
			debugTopColorRect.size = topSize # TODO remove hardcode
			if Debugger.DEBUG_IS_ACTIVE:
				add_child(debugTopColorRect)

			var botPosition := patternPosition - (Vector2(0, -6.5 * GameConstants.DISTANCE_BETWEEN_PATHES))
			var botSize := Vector2(horizontalSizePerChunk, 65)
			var debugBotColorRect := ColorRect.new()
			debugBotColorRect.position = botPosition
			debugBotColorRect.size = botSize
			if Debugger.DEBUG_IS_ACTIVE:
				add_child(debugBotColorRect)

			var biomeProps := biome.generateBiomeProps()
			for biomeProp in biomeProps:
				var chosenSide: ColorRect
				match randi_range(0, 1):
					0: chosenSide = debugTopColorRect
					1: chosenSide = debugBotColorRect

				var propSprite := Sprite2D.new()
				propSprite.texture = biomeProp
				propSprite.global_position = Vector2(
					randf_range(chosenSide.global_position.x, chosenSide.global_position.x + chosenSide.size.x),
					randf_range(chosenSide.global_position.y, chosenSide.global_position.y + chosenSide.size.y))
				add_child(propSprite)

		# Interactibles generation
		var fullBiomeDistance := horizontalSizePerChunk * biome.numberOfChunks
		for i in GameConstants.NUMBER_OF_PATHES:
			var generatedBiome: Array = biome.generateBiome()

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
			for biomeEntityInfo in generatedBiome:
				var positionChange := randf_range(_MINIMAL_DISTANCE_BETWEEN_BIOME_ENTITIES, distanceForOneEntity + distanceRemainder)
				biomeEntityPosition.x += positionChange

				var biomeEntity := _ENEMY_SCENE.instantiate()
				if biomeEntityInfo is BiomeBonus:
					biomeEntity = _BONUS_SCENE.instantiate()
				elif biomeEntityInfo is BiomeObstacle:
					biomeEntity = _OBSTACLE_SCENE.instantiate()
				biomeEntity.setup(biomeEntityInfo, biomeEntityPosition)
				add_child(biomeEntity)

				distanceRemainder = distanceForOneEntity + distanceRemainder - positionChange

			# Spawn boss. Final boss spawned only in middle, cuz he will be big.
			if not biome.boss.finalBoss or biome.boss.finalBoss and i == GameConstants.NUMBER_OF_MIDDLE_PATH:
				var additionalShift := _FINAL_BOSS_SHIFT if biome.boss.finalBoss else 0
				var bossPosition := Vector2(fullBiomeDistance + biomeDistanceShift - additionalShift, biomeEntityPosition.y)
				var bossEntity := _ENEMY_SCENE.instantiate()
				bossEntity.setup(biome.boss, bossPosition)
				add_child(bossEntity)

		biomeDistanceShift += fullBiomeDistance
		_playerRightCameraLimit += biomeDistanceShift

func _onPlayer_died() -> void:
	%RestartGameHintText.show()
	_canRestartGame = true

func _onFinalBossDefeated() -> void:
	GameConstants.player.isMovementDisabled = false
	GameConstants.player.changeAnimation("idle")
	$AnimationPlayer.play("ending_transition")
