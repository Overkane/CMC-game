extends Resource
class_name Biome

enum BiomeType { FOREST, DESERT, SNOW }

@export var biomeType: BiomeType
@export var numberOfChunks := 4
@export var boss: BiomeEnemy
@export var enemyList: Array[BiomeEnemy]
@export var bonusList: Array[BiomeBonus]
@export var obstacleList: Array[BiomeObstacle]
@export var numberOfEnemies := 4
@export var numberOfBonuses := 4
@export var numberOfObstacles := 4


func generateBiome() -> Array[BiomeEntity]:
	var generatedBiome: Array[BiomeEntity]

	if not enemyList.is_empty():
		for i in numberOfEnemies:
			generatedBiome.append(enemyList.pick_random())
	if not bonusList.is_empty():
		for i in numberOfBonuses:
			generatedBiome.append(bonusList.pick_random())
	if not obstacleList.is_empty():
		for i in numberOfObstacles:
			generatedBiome.append(obstacleList.pick_random())

	generatedBiome.shuffle()
	return generatedBiome
