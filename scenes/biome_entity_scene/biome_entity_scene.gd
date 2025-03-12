extends Area2D

func setup(biomeEntity: BiomeEntity, biomeEntityPosition: Vector2) -> void:
	$Sprite2D.texture = biomeEntity.sprite
	global_position = biomeEntityPosition
