extends CanvasLayer

@onready var button_load: Button = $VBoxContainer/Button_Load
@onready var button_save: Button = $VBoxContainer/Button_Save

var is_paused : bool = false

func _ready() -> void:
	hide_pause_menu()
	button_save.pressed.connect( _on_save_pressed )
	button_load.pressed.connect( _on_load_pressed )

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			show_pause_menu()
		else:
			hide_pause_menu()
		get_viewport().set_input_as_handled()

func show_pause_menu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true
	button_save.grab_focus()

func hide_pause_menu() -> void:
	get_tree().paused = false
	visible = false
	is_paused = false

func _on_save_pressed() -> void:
	if not is_paused:
		return
	SaveManager.save_game()
	hide_pause_menu()


func _on_load_pressed() -> void:
	if not is_paused:
		return
	hide_pause_menu()
	#await get_tree().process_frame
	SaveManager.load_game()
	await LevelManager.level_load_started
	pass
