extends Area2D
class_name Player

signal died

const _MIN_SPEED = 50
const _MAX_SPEED = _MIN_SPEED * 2
const _INITIAL_SPEED = (_MIN_SPEED + _MAX_SPEED) / 2

@export var _baseStats: BaseStats

var isDead := false
var isMovementDisabled := false

var _currentSpeed := _INITIAL_SPEED
@warning_ignore("narrowing_conversion")
var _currentPathNumber: int = round(GameConstants.NUMBER_OF_PATHES / 2.0)
var _currentMoveAnimation := "walk"

@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	area_entered.connect(_onAreaEntered)

	%HPLabel.text = str(_baseStats.currentHP)
	%DamageLabel.text = str(_baseStats.currentDamage)
	%ArmorLabel.text = str(_baseStats.currentArmor)

func _physics_process(delta: float) -> void:
	if not isDead and not isMovementDisabled:
		_applyMovement(delta)


func changeHP(value: int) -> void:
	_baseStats.currentHP += value
	%HPLabel.text = str(_baseStats.currentHP)
	if _baseStats.currentHP <= 0:
		isDead = true
		$AnimatedSprite2D.play("death")
		await $AnimatedSprite2D.animation_finished
		died.emit()

func changeSpeed(value: int) -> void:
	_currentSpeed += value
	if _currentSpeed >= (_INITIAL_SPEED + _MAX_SPEED) / 2:
		_currentMoveAnimation = "run"
	else:
		_currentMoveAnimation = "walk"
	$AnimatedSprite2D.play(_currentMoveAnimation)

func changeAnimation(animationName: String) -> void:
	$AnimatedSprite2D.play(animationName)


func _applyMovement(delta: float) -> void:
	# Base horizontal movement
	global_position += Vector2.RIGHT * _currentSpeed * delta

	# Vertical movement
	var verticalVector := Vector2.ZERO
	if Input.is_action_just_pressed("move_up") and _currentPathNumber > 1:
		verticalVector = Vector2.UP
		_currentPathNumber -= 1
	elif Input.is_action_just_pressed("move_down") and _currentPathNumber < GameConstants.NUMBER_OF_PATHES:
		verticalVector = Vector2.DOWN
		_currentPathNumber += 1
	global_position += verticalVector * GameConstants.DISTANCE_BETWEEN_PATHES


func _onAreaEntered(body: Node2D) -> void:
	assert(body.has_method("interact"), str(body) + " doesn't have 'interact()' method.")
	body.interact()

	if not isDead:
		var attackVariant := randi_range(1, 3)
		$AnimatedSprite2D.play("attack%s" % attackVariant)
		await $AnimatedSprite2D.animation_finished
		# In case dead during attack animation
		if not isDead:
			$AnimatedSprite2D.play(_currentMoveAnimation)
