extends Area2D

var biomeBonusEntity: BiomeBonus

func setup(biomeEntity: BiomeBonus, biomeEntityPosition: Vector2) -> void:
	$Sprite2D.texture = biomeEntity.sprite
	global_position = biomeEntityPosition
	biomeBonusEntity = biomeEntity

func interact() -> void:
	biomeBonusEntity.applyBonus()
	_destroy()

func _destroy() -> void:
	queue_free()
