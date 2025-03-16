extends Area2D
class_name Enemy

const _FINAL_BOSS_SCALE := 7

var _baseStats: BaseStats
var _damageToThePlayer: int
var _enemyExp: int
var _finalBoss: bool


func setup(biomeEntity: BiomeEnemy, biomeEntityPosition: Vector2) -> void:
	EventBus.playerStatsChanged.connect(_updateTotalDamageToThePlayer)

	$Sprite2D.texture = biomeEntity.sprite
	_baseStats = biomeEntity.enemyStats
	global_position = biomeEntityPosition

	_enemyExp = biomeEntity.enemyExp

	%HPLabel.text = str(_baseStats.maxHP)
	%DamageLabel.text = str(_baseStats.damage)
	%ArmorLabel.text = str(_baseStats.armor)
	_updateTotalDamageToThePlayer()

	if biomeEntity.finalBoss:
		_finalBoss = true
		scale *= _FINAL_BOSS_SCALE

func interact() -> void:
	GameConstants.player.changeHP(-_damageToThePlayer)
	if not GameConstants.player.isDead:
		if _finalBoss:
			EventBus.finalBossDefeated.emit()
			var tween := create_tween()
			tween.tween_property(self, "rotation", PI / 2, 1)
		else:
			_destroy()


func _updateTotalDamageToThePlayer() -> void:
	_damageToThePlayer = _calculatePlayerHPAfterBattle()
	%DamageToPlayerLabel.text = str(_damageToThePlayer)

func _calculatePlayerHPAfterBattle() -> int:
	var playerHP: int = GameConstants.player.currentHP
	var enemyHP := _baseStats.maxHP

	while true:
		enemyHP -= max(GameConstants.player.currentDamage - _baseStats.armor, 1)
		if enemyHP <= 0:
			break

		playerHP -= max(_baseStats.damage - GameConstants.player.currentArmor, 1)
		if playerHP <= 0:
			break

	return GameConstants.player.currentHP - playerHP

func _destroy() -> void:
	EventBus.enemyDefeated.emit(_enemyExp)
	queue_free()
