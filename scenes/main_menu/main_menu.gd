extends Control

enum SoundBus { MASTER, MUSIC, SFX }

const _NUMBER_OF_BUTTONS := 3
const _WORLD_SCENE := preload("res://scenes/levels/game_world.tscn")
const _DEFAULT_MASTER_AUDIO_VOLUME := 0.65

var _currentButtonNumber := 2


func _ready() -> void:
	%PlayButton.pressed.connect(_onPlayButton_pressed)
	%OptionsButton.pressed.connect(_onOptionsButton_pressed)
	%OptionsBackButton.pressed.connect(_onOptionsBackButton_pressed)
	%CreditsButton.pressed.connect(_onCreditsButton_pressed)
	%CreditsBackButton.pressed.connect(_onCreditsBackButton_pressed)
	%MasterSlider.value_changed.connect(_onMasterSlider_valueChanged)
	%MusicSlider.value_changed.connect(_onMusicSlider_valueChanged)
	%SFXSlider.value_changed.connect(_onSFXSlider_valueChanged)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	%OptionsButton.call_deferred("grab_focus")

	_setDefaultAudioSettings()

func _input(event: InputEvent) -> void:
	if %PlayerSprite.visible:
		_movePlayerSprite(event)


func _movePlayerSprite(event: InputEvent) -> void:
	var verticalVector := Vector2.ZERO
	if event.is_action_pressed("move_up") and _currentButtonNumber > 1:
		verticalVector = Vector2.UP
		_currentButtonNumber -= 1
	elif event.is_action_pressed("move_down") and _currentButtonNumber < _NUMBER_OF_BUTTONS:
		verticalVector = Vector2.DOWN
		_currentButtonNumber += 1
	%PlayerSprite.global_position += verticalVector * GameConstants.DISTANCE_BETWEEN_PATHES

func _setDefaultAudioSettings() -> void:
	AudioServer.set_bus_volume_db(SoundBus.MASTER, linear_to_db(_DEFAULT_MASTER_AUDIO_VOLUME))

	%MasterSlider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(SoundBus.MASTER)))
	%MusicSlider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(SoundBus.MUSIC)))
	%SFXSlider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(SoundBus.SFX)))


func _onPlayButton_pressed() -> void:
	%MainMenu.hide()
	%PlayerSprite.play("run")
	%AnimationPlayer.play("game_start")
	await %AnimationPlayer.animation_finished
	get_tree().change_scene_to_packed(_WORLD_SCENE)

func _onOptionsButton_pressed() -> void:
	%MainMenu.hide()
	%PlayerSprite.hide()
	%OptionsContainer.show()
	%OptionsBackButton.call_deferred("grab_focus")

func _onOptionsBackButton_pressed() -> void:
	%MainMenu.show()
	%PlayerSprite.show()
	%OptionsContainer.hide()
	%OptionsButton.call_deferred("grab_focus")

func _onCreditsButton_pressed() -> void:
	%MainMenu.hide()
	%PlayerSprite.hide()
	%CreditsContainer.show()
	%CreditsBackButton.call_deferred("grab_focus")

func _onCreditsBackButton_pressed() -> void:
	%MainMenu.show()
	%PlayerSprite.show()
	%CreditsContainer.hide()
	%CreditsButton.call_deferred("grab_focus")

func _onMasterSlider_valueChanged(value: float) -> void:
	AudioServer.set_bus_volume_db(SoundBus.MASTER, linear_to_db(value))

func _onMusicSlider_valueChanged(value: float) -> void:
	AudioServer.set_bus_volume_db(SoundBus.MUSIC, linear_to_db(value))

func _onSFXSlider_valueChanged(value: float) -> void:
	AudioServer.set_bus_volume_db(SoundBus.SFX, linear_to_db(value))
