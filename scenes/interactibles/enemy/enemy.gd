extends Area2D
class_name Enemy

var _baseStats: BaseStats
var _damageToThePlayer: int


func setup(biomeEntity: BiomeEnemy, biomeEntityPosition: Vector2) -> void:
	EventBus.playerStatsChanged.connect(_updateTotalDamageToThePlayer)

	$Sprite2D.texture = biomeEntity.sprite
	_baseStats = biomeEntity.enemyStats
	global_position = biomeEntityPosition

	%HPLabel.text = str(_baseStats.currentHP)
	%DamageLabel.text = str(_baseStats.currentDamage)
	%ArmorLabel.text = str(_baseStats.currentArmor)
	_updateTotalDamageToThePlayer()

func interact() -> void:
	GameConstants.player.changeHP(-_damageToThePlayer)
	_destroy()


func _updateTotalDamageToThePlayer() -> void:
	_damageToThePlayer = _calculatePlayerHPAfterBattle()
	%DamageToPlayerLabel.text = str(_damageToThePlayer)

func _calculatePlayerHPAfterBattle() -> int:
	var playerStats: BaseStats = GameConstants.player._baseStats

	var playerHP := playerStats.currentHP
	var enemyHP := _baseStats.currentHP

	while true:
		enemyHP -= max(playerStats.currentDamage - _baseStats.currentArmor, 1)
		if enemyHP <= 0:
			break

		playerHP -= max(_baseStats.currentDamage - playerStats.currentArmor, 1)
		if playerHP <= 0:
			break

	return playerStats.currentHP - playerHP

func _destroy() -> void:
	queue_free()
