extends Area2D
class_name Player

const _MIN_SPEED = 50.0
const _MAX_SPEED = _MIN_SPEED * 2
const _INITIAL_SPEED = (_MIN_SPEED + _MAX_SPEED) / 2.0

@export var _baseStats: BaseStats

var _currentSpeed := _INITIAL_SPEED
@warning_ignore("narrowing_conversion")
var _currentPathNumber: int = round(GameConstants.NUMBER_OF_PATHES / 2.0)


func _ready() -> void:
	area_entered.connect(_onAreaEntered)

	%HPLabel.text = str(_baseStats.currentHP)
	%DamageLabel.text = str(_baseStats.currentDamage)
	%ArmorLabel.text = str(_baseStats.currentArmor)

func _physics_process(delta: float) -> void:
	# Base horizontal movement
	global_position += Vector2.RIGHT * _currentSpeed * delta

	# Vertical movement
	var verticalVector := Vector2.ZERO
	if Input.is_action_just_pressed("left") and _currentPathNumber > 1:
		verticalVector = Vector2.UP
		_currentPathNumber -= 1
	elif Input.is_action_just_pressed("right") and _currentPathNumber < GameConstants.NUMBER_OF_PATHES:
		verticalVector = Vector2.DOWN
		_currentPathNumber += 1
	global_position += verticalVector * GameConstants.DISTANCE_BETWEEN_PATHES


func changeHP(value: int) -> void:
	_baseStats.currentHP += value
	%HPLabel.text = str(_baseStats.currentHP)
	if _baseStats.currentHP <= 0:
		queue_free() # TODO lose condition


func _onAreaEntered(body: Node2D) -> void:
	assert(body.has_method("interact"), str(body) + " doesn't have 'interact()' method.")
	body.interact()
