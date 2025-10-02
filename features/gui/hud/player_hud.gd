extends CanvasLayer

@export var button_focus_audio : AudioStream = preload("res://title_scene/audio/menu_focus.wav")
@export var button_select_audio : AudioStream = preload("res://title_scene/audio/menu_select.wav")

var hearts : Array[ HeartGUI ] = []
var _in_transition: bool = false

@onready var game_over: Control = $Control/GameOver
@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer
@onready var button_continue: Button = $Control/GameOver/VBoxContainer/ContinueButton
@onready var button_back_title: Button = $Control/GameOver/VBoxContainer/BackTitleButton
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	for child in $Control/HeartsHFlowContainer.get_children():
		if child is HeartGUI:
			hearts.append(child)
			child.visible = false

	hide_game_over_screen()

	button_continue.focus_entered.connect( play_audio.bind( button_focus_audio ) )
	button_back_title.focus_entered.connect( play_audio.bind( button_focus_audio ) )

	# Route both buttons through a single guarded handler
	button_continue.pressed.connect(func(): _on_choice("continue"))
	button_back_title.pressed.connect(func(): _on_choice("back"))

	LevelManager.level_load_started.connect( hide_game_over_screen )

func _on_choice(action: String) -> void:
	if _in_transition:
		return
	_in_transition = true
	_disable_menu_inputs()

	play_audio(button_select_audio)
	await fade_to_black()
	PlayerManager.player.revive_player()
	match action:
		"continue":
			SaveManager.load_game()
		"back":
			LevelManager.load_new_level("res://title_scene/title_scene.tscn", "", Vector2.ZERO)

	# If you come back to this screen later, show_game_over_screen() will re-enable inputs.

func _disable_menu_inputs() -> void:
	# Stop any further clicks/keyboard on the menu while transitioning
	button_continue.disabled = true
	button_back_title.disabled = true
	game_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Optional: also remove keyboard focus so Enter/Space won’t trigger anything
	button_continue.focus_mode = Control.FOCUS_NONE
	button_back_title.focus_mode = Control.FOCUS_NONE

func _enable_menu_inputs(can_continue: bool) -> void:
	button_continue.disabled = not can_continue
	button_back_title.disabled = false
	game_over.mouse_filter = Control.MOUSE_FILTER_STOP
	button_continue.focus_mode = Control.FOCUS_ALL
	button_back_title.focus_mode = Control.FOCUS_ALL
	if can_continue:
		button_continue.grab_focus()
	else:
		button_back_title.grab_focus()
	_in_transition = false

func update_hp(_hp : int, _max_hp : int) -> void:
	update_max_hp(_max_hp)
	for i in _max_hp:
		update_heart(i, _hp)

func update_heart(_index : int, _hp : int) -> void:
	var _value : int = clampi(_hp - _index * 2, 0, 2)
	hearts[_index].value = _value

func update_max_hp(_max_hp : int) -> void:
	var _heart_count : int = roundi(_max_hp * 0.5)
	for i in hearts.size():
		hearts[i].visible = i < _heart_count

func hide_game_over_screen() -> void:
	game_over.visible = false
	game_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over.modulate = Color(1,1,1,0)

func show_game_over_screen() -> void:
	game_over.visible = true
	game_over.mouse_filter = Control.MOUSE_FILTER_STOP
	animation_player.play("show_game_over")
	await animation_player.animation_finished
	var can_continue : bool = SaveManager.get_save_file() != null
	_enable_menu_inputs(can_continue)

func play_audio(_a : AudioStream) -> void:
	audio_stream_player.stream = _a
	audio_stream_player.play()

func fade_to_black() -> bool:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	return true
