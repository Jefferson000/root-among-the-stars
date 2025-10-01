@tool
@icon ( "res://features/gui/dialog_system/icons/question_bubble.svg" )
class_name DialogChoice extends DialogItem

var dialog_branches : Array[ DialogBranch ]

func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_dialog_branches():
		return []
	return [ "Required at least two DialogBranches node." ]

func _ready() -> void:
	super()
	for c in get_children():
		if c is DialogBranch:
			dialog_branches.append( c )

func _set_editor_display() -> void:
	set_realted_text()
	if dialog_branches.size() < 2:
		return
	example_dialog.set_dialog_choice( self )
	pass

func set_realted_text() -> void:
	var parent = get_parent()
	var related_text = parent.get_child( self.get_index() - 1 )

	if related_text is DialogText:
		example_dialog.set_dialog_text( related_text )
		example_dialog.content.visible_characters = -1

func _check_for_dialog_branches() -> bool:
	var _count : int = 0
	for c in get_children():
		if c is DialogBranch:
			_count += 1
			if _count > 1:
				return true
	return false
