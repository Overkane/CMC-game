extends BiomeEntity
class_name BiomeBonus

enum BonusType { DAMAGE, ARMOR, SPEED, HP_RESTORE }

@export var bonusType: BonusType
@export var bonusValue: int


func applyBonus() -> void:
	if bonusType == BonusType.DAMAGE:
		GameConstants.player.changeDamage(bonusValue)
	elif bonusType == BonusType.ARMOR:
		GameConstants.player.changeArmor(bonusValue)
	elif bonusType == BonusType.SPEED:
		GameConstants.player.changeSpeed(bonusValue)
	elif bonusType == BonusType.HP_RESTORE:
		GameConstants.player.changeHP(GameConstants.player.maxHP * bonusValue / 100)
