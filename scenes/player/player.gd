extends Area2D
class_name Player

signal died

const _MIN_SPEED := 55
const _MAX_SPEED := _MIN_SPEED * 3
@warning_ignore("integer_division")
const _INITIAL_SPEED := (_MIN_SPEED + _MAX_SPEED) / 2
const _SPEED_INCREASE_PER_SECOND := 1

@export var _baseStats: BaseStats
@export var _levelingSystem: LevelingSystem

var maxHP: int:
	set(value):
		var oldMaxHP := maxHP
		maxHP = value
		if value > 0:
			currentHP += maxHP - oldMaxHP
var currentHP: int:
	set(value):
		currentHP = clamp(value, 0, maxHP)
var currentDamage := 0
var currentArmor := 0
var isDead := false
var isMovementDisabled := false

var _baseDamage := 0:
	set(value):
		_baseDamage = value
		currentDamage = _baseDamage * _speedStatModifier
var _baseArmor := 0:
	set(value):
		_baseArmor = value
		currentArmor = _baseArmor * _speedStatModifier
var _currentPathNumber := 3
var _currentMoveAnimation := "walk"
var _speedStatModifier := 1.0:
	set(value):
		var oldSpeedModifier = _speedStatModifier
		_speedStatModifier = value
		if _speedStatModifier != oldSpeedModifier:
			# Trigger stat setters to recalculate with new speed modifier
			_updatePlayerStatsUI()
var _currentSpeed := _INITIAL_SPEED:
	set(value):
		_currentSpeed = clamp(value, _MIN_SPEED, _MAX_SPEED)
		# High speed, positive bonus to stats.
		if _currentSpeed >= (_INITIAL_SPEED + _MAX_SPEED) / 2:
			_speedStatModifier = 1.5
			%SpeedIconMinus.hide()
			%SpeedIcon.hide()
			%SpeedIconPlus.show()
		# Slow speed, negative bonus to stats.
		elif _currentSpeed <= (_INITIAL_SPEED + _MIN_SPEED) / 2:
			_speedStatModifier = 0.5
			%SpeedIconMinus.show()
			%SpeedIcon.hide()
			%SpeedIconPlus.hide()
		else:
			_speedStatModifier = 1
			%SpeedIconMinus.hide()
			%SpeedIcon.show()
			%SpeedIconPlus.hide()

@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	area_entered.connect(_onAreaEntered)
	$SpeedTimer.timeout.connect(func():
		if not isDead and not isMovementDisabled:
			changeSpeed(_SPEED_INCREASE_PER_SECOND)
		$SpeedTimer.start())
	_levelingSystem.levelUp.connect(_onLevelingSystem_levelUp)
	EventBus.enemyDefeated.connect(_onEnemyDefeated)

	maxHP = _baseStats.maxHP
	_baseDamage = _baseStats.damage
	_baseArmor = _baseStats.armor

	_updatePlayerStatsUI()
	$SpeedTimer.start()

func _physics_process(delta: float) -> void:
	if not isDead and not isMovementDisabled:
		_applyMovement(delta)


func changeHP(value: int) -> void:
	currentHP += value

	# On taking damage you slow down based on damage.
	if value < 0:
		_currentSpeed += value

	_updatePlayerStatsUI()
	if currentHP <= 0:
		isDead = true
		$AnimatedSprite2D.play("death")
		await $AnimatedSprite2D.animation_finished
		died.emit()

func changeDamage(value: int) -> void:
	_baseDamage += value
	_updatePlayerStatsUI()

func changeArmor(value: int) -> void:
	_baseArmor += value
	_updatePlayerStatsUI()

func changeSpeed(value: int) -> void:
	_currentSpeed += value

	@warning_ignore("integer_division")
	if _currentSpeed >= (_INITIAL_SPEED + _MAX_SPEED) / 2:
		_currentMoveAnimation = "run"
	else:
		_currentMoveAnimation = "walk"
	$AnimatedSprite2D.play(_currentMoveAnimation)
	_updatePlayerStatsUI()

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
	%HPLabel.text = "%s/%s" % [currentHP, maxHP]
	%DamageLabel.text = str(currentDamage)
	%ArmorLabel.text = str(currentArmor)
	%SpeedLabel.text = str(_currentSpeed)
	EventBus.playerStatsChanged.emit()


func _onAreaEntered(body: Node2D) -> void:
	assert(body.has_method("interact"), str(body) + " doesn't have 'interact()' method.")
	body.interact()

	if not isDead and body is Enemy:
		var attackVariant := randi_range(1, 3)
		$AnimatedSprite2D.play("attack%s" % attackVariant)
		await $AnimatedSprite2D.animation_finished
		# In case dead during attack animation
		if not isDead and not isMovementDisabled:
			$AnimatedSprite2D.play(_currentMoveAnimation)

func _onEnemyDefeated(expGained: int) -> void:
	_levelingSystem.increaseExp(expGained)

func _onLevelingSystem_levelUp(currentLevel: int) -> void:
	var levelForStatIncrease := currentLevel - 1
	# Reduced value for max hp increase, cuz otherwise it would be too strong.
	@warning_ignore("integer_division")
	maxHP += levelForStatIncrease * _baseStats.maxHP / 10
	_baseDamage += levelForStatIncrease * _baseStats.damage
	_baseArmor += levelForStatIncrease * _baseStats.armor
	_updatePlayerStatsUI()
