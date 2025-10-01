@tool
@icon ( "res://features/gui/dialog_system/icons/question_bubble.svg" )
class_name DialogChoice extends DialogItem

var dialog_branches : Array[ DialogBranch ]

func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_dialog_branches():
		return []
	return [ "Required at least two DialogBranches node." ]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for c in get_children():
		if c is DialogBranch:
			dialog_branches.append( c )

func _check_for_dialog_branches() -> bool:
	var _count : int = 0
	for c in get_children():
		if c is DialogBranch:
			_count += 1
			if _count > 1:
				return true
	return false
