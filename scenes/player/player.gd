extends Area2D
class_name Player

signal died

const _MIN_SPEED := 50
const _MAX_SPEED := _MIN_SPEED * 2
@warning_ignore("integer_division")
const _INITIAL_SPEED := (_MIN_SPEED + _MAX_SPEED) / 2

@export var _baseStats: BaseStats
@export var _levelingSystem: LevelingSystem

var currentHP: int
var currentDamage: int
var currentArmor: int
var isDead := false
var isMovementDisabled := false

var _currentSpeed := _INITIAL_SPEED
var _currentPathNumber := 3
var _currentMoveAnimation := "walk"
var _maxHP: int:
	set(value):
		var oldMaxHP = _maxHP
		_maxHP = value
		if value > 0:
			currentHP += _maxHP - oldMaxHP

@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	area_entered.connect(_onAreaEntered)
	_levelingSystem.levelUp.connect(_onLevelingSystem_levelUp)
	EventBus.enemyDefeated.connect(_onEnemyDefeated)

	_maxHP = _baseStats.maxHP
	currentDamage = _baseStats.damage
	currentArmor = _baseStats.armor

	_updatePlayerStatsUI()

func _physics_process(delta: float) -> void:
	if not isDead and not isMovementDisabled:
		_applyMovement(delta)


func changeHP(value: int) -> void:
	currentHP += value
	_updatePlayerStatsUI()
	if currentHP <= 0:
		isDead = true
		$AnimatedSprite2D.play("death")
		await $AnimatedSprite2D.animation_finished
		died.emit()

func changeSpeed(value: int) -> void:
	_currentSpeed += value
	@warning_ignore("integer_division")
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

func _updatePlayerStatsUI() -> void:
	%HPLabel.text = "%s/%s" % [currentHP, _maxHP]
	%DamageLabel.text = str(currentDamage)
	%ArmorLabel.text = str(currentArmor)
	EventBus.playerStatsChanged.emit()


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

func _onEnemyDefeated(expGained: int) -> void:
	_levelingSystem.increaseExp(expGained)

func _onLevelingSystem_levelUp(currentLevel: int) -> void:
	var levelForStatIncrease = currentLevel - 1
	# Reduced value for max hp increase, cuz otherwise it would be too strong.
	@warning_ignore("integer_division")
	_maxHP += levelForStatIncrease * _baseStats.maxHP / 10
	currentDamage += levelForStatIncrease * _baseStats.damage
	currentArmor += levelForStatIncrease * _baseStats.armor
	_updatePlayerStatsUI()
