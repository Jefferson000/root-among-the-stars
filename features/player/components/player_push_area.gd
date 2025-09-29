extends Area2D

func _ready() -> void:
	body_entered.connect( _on_body_entered )
	body_exited.connect( _on_body_exited )


func _on_body_entered( _b : Node2D ) -> void:
	if _b is PushableStatue:
		_b.push_direction = PlayerManager.player.direction

func _on_body_exited( _b : Node2D ) -> void:
	if _b is PushableStatue:
		_b.push_direction = Vector2.ZERO
