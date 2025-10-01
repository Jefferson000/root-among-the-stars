@tool
@icon ( "res://features/gui/dialog_system/icons/answer_bubble.svg" )
class_name DialogBranch extends DialogItem

@export var text : String = "ok..." : set = _set_text

var dialog_items : Array[ DialogItem ]

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	for c in get_children():
		if c is DialogItem:
			dialog_items.append(c)

func _set_editor_display() -> void:
	var parent = get_parent()
	if parent is DialogChoice:
		set_related_text()
		if parent.dialog_branches.size() < 2:
			return
		example_dialog.set_dialog_choice( parent as DialogChoice )

func set_related_text() -> void:
	var parent = get_parent()
	var parent2 = parent.get_parent()
	var related_text = parent2.get_child( parent.get_index() - 1 )

	if related_text is DialogText:
		example_dialog.set_dialog_text( related_text )
		example_dialog.content.visible_characters = -1

func _set_text( value : String ) -> void:
	text = value
	if Engine.is_editor_hint():
		if example_dialog != null:
			_set_editor_display()
