extends Area2D

var _damage := 0

func setup(biomeEntity: BiomeObstacle, biomeEntityPosition: Vector2) -> void:
	$Sprite2D.texture = biomeEntity.sprite
	$Sprite2D.hframes = biomeEntity.numberOfHorizontalFrames
	global_position = biomeEntityPosition
	_damage = biomeEntity.damage


func interact() -> void:
	var tween := create_tween()
	tween.tween_property($Sprite2D, "frame", $Sprite2D.hframes - 1, 0.5)
	GameConstants.player.changeHP(-_damage)
