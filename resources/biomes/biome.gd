extends Resource
class_name Biome

# Chosen tileset depends on biome type, so it should be in corresponding order with tileset patterns.
enum BiomeType { FOREST, DESERT, SNOW }
enum EntityType { ENEMY, OBSTACLE, BONUS, PROP }

@export var biomeType: BiomeType
@export var numberOfChunks := 4
@export_category("Enemies")
@export var boss: BiomeEnemy
@export var _enemyListWithWeights: Dictionary[BiomeEnemy, float]
@export var _numberOfEnemies := 4
@export_category("Obstacles")
@export var _obstacleListWithWeights: Dictionary[BiomeObstacle, float]
@export var _numberOfObstacles := 4
@export_category("Bonuses")
@export var _bonusListWithWeights: Dictionary[BiomeBonus, float]
@export var _numberOfBonuses := 4
@export_category("Props")
@export var _propSpritesWithWeights: Dictionary[Texture2D, float]
@export var _numberOfPropsPerChunk := 20

var _entityWeights: Dictionary[EntityType, float]


func generateBiome() -> Array:
	var generatedBiome: Array

	if not _enemyListWithWeights.is_empty():
		generatedBiome = _generatedEntityListBasedOnWeight(EntityType.ENEMY, _enemyListWithWeights, _numberOfEnemies)
	if not _bonusListWithWeights.is_empty():
		generatedBiome = _generatedEntityListBasedOnWeight(EntityType.BONUS, _bonusListWithWeights, _numberOfBonuses)
	if not _obstacleListWithWeights.is_empty():
		generatedBiome = _generatedEntityListBasedOnWeight(EntityType.OBSTACLE, _obstacleListWithWeights, _numberOfObstacles)

	return generatedBiome

func generateBiomeProps() -> Array:
	var generatedBiomeProps: Array

	if not _propSpritesWithWeights.is_empty():
		generatedBiomeProps = _generatedEntityListBasedOnWeight(EntityType.PROP, _propSpritesWithWeights, _numberOfPropsPerChunk)

	return generatedBiomeProps


func _generatedEntityListBasedOnWeight(entityType: EntityType, entityListWithWeights: Dictionary, numberOfEntities: int) -> Array:
	var generatedEntityList: Array
	var totalWeight := 0.0

	if not _entityWeights.has(entityType):
		for entity in entityListWithWeights:
			totalWeight += entityListWithWeights[entity]
		_entityWeights[entityType] = totalWeight
	else:
		totalWeight = _entityWeights[entityType]

	for i in numberOfEntities:
		var chosenWeight = randf_range(0, totalWeight)
		for entity in entityListWithWeights:
			chosenWeight -= entityListWithWeights[entity]
			if chosenWeight <= 0:
				generatedEntityList.append(entity)
				break

	return generatedEntityList
