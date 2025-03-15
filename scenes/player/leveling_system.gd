extends Node
class_name LevelingSystem

signal levelUp(currentLevel: int)

@export var _maxLevel := 8
@export var _expIncreasePerLevel := 8
@export var _expForFirstLevel := 4

var _expPerLevelList: Array[int]
var _currentLevel := 1
var _currentExp := 0


func _ready() -> void:
	var expPerLevel := _expForFirstLevel
	for i in range(1, _maxLevel):
		_expPerLevelList.push_back(expPerLevel)
		expPerLevel += i * _expIncreasePerLevel


func increaseExp(value: int) -> void:
	if _currentLevel == _maxLevel:
		return

	_currentExp += value
	if _currentExp >= _expPerLevelList[_currentLevel - 1]:
		_increaseLevel()


func _increaseLevel() -> void:
	_currentLevel += 1
	levelUp.emit(_currentLevel)
