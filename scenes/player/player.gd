extends Area2D

const _MIN_SPEED = 50.0
const _MAX_SPEED = _MIN_SPEED * 2
const _INITIAL_SPEED = (_MIN_SPEED + _MAX_SPEED) / 2.0
const _DISTANCE_BETWEEN_PATHS = 48 # TODO, depends on tile size
const _MAX_PATHS_NUMBER = 5

var _currentSpeed := _INITIAL_SPEED
@warning_ignore("narrowing_conversion")
var _currentPathNumber: int = round(_MAX_PATHS_NUMBER / 2.0)


func _physics_process(delta: float) -> void:
	# Base horizontal movement
	global_position += Vector2.RIGHT * _currentSpeed * delta

	# Vertical movement
	var verticalVector := Vector2.ZERO
	if Input.is_action_just_pressed("left") and _currentPathNumber > 1:
		verticalVector = Vector2.UP
		_currentPathNumber -= 1
	elif Input.is_action_just_pressed("right") and _currentPathNumber < _MAX_PATHS_NUMBER:
		verticalVector = Vector2.DOWN
		_currentPathNumber += 1
	global_position += verticalVector * _DISTANCE_BETWEEN_PATHS
