@tool
@icon("res://features/gui/dialog_system/icons/chat_bubbles.svg")
class_name DialogInteraction extends Area2D

signal player_interacted
signal finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var enabled : bool = true

var dialog_items : Array[ DialogItem ]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for c in get_children():
		if c is DialogItem:
			dialog_items.append(c)

	area_entered.connect( _on_area_enter )
	area_exited.connect( _on_area_exit )

func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_dialog_items():
		return []
	return [ "Required at least one DialogItem node." ]

func _check_for_dialog_items() -> bool:
	for c in get_children():
		if c is DialogItem:
			return true
	return false

func player_interact() -> void:
	player_interacted.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	DialogSystem.show_dialog( dialog_items )
	DialogSystem.finished.connect( _on_dialog_finished )

func _on_area_enter( _a : Area2D ) -> void:
	if enabled == false or dialog_items.size() == 0:
		return
	animation_player.play("show")
	PlayerManager.interact_pressed.connect( player_interact )

func _on_area_exit( _a : Area2D ) -> void:
	animation_player.play("hide")
	PlayerManager.interact_pressed.disconnect( player_interact )

func _on_dialog_finished() -> void:
	DialogSystem.finished.disconnect( _on_dialog_finished )
	finished.emit()
