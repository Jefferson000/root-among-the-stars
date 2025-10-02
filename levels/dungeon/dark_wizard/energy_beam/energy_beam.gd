class_name EnergyBeam extends Node2D

@export var use_timer : bool = false
@export var time_between_attacks : float = 3.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer



func _ready() -> void:
	print(use_timer)
	if use_timer:
		attack_delay()

func attack() -> void:
	animation_player.play("attack")
	await animation_player.animation_finished
	animation_player.play( "default" )
	if use_timer:
		attack_delay()

func attack_delay() -> void:
	print(" attack_delay before timer")
	await get_tree().create_timer( time_between_attacks ).timeout
	print(" attack_delay after timer ")
	attack()
