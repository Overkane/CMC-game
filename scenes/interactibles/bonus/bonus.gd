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
	var PickupSound = $PickupSound
	PickupSound.reparent(get_tree().root)
	PickupSound.playing = true
	PickupSound.finished.connect(func(): PickupSound.queue_free())
	queue_free()
