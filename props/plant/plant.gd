class_name Plant extends Node2D


func _ready() -> void:
	$HitBox.damaged.connect(take_damage)

func take_damage( _damage: HurtBox ) -> void:
	queue_free()
