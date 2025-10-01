class_name State_Attack extends State

var attacking : bool = false

@export var attack_sound : AudioStream
@export_range(1, 20,0.5) var decelerate_speed : float = 5.0

@onready var animation_player : AnimationPlayer = $"../../AnimationPlayer"
@onready var sword_animation : AnimationPlayer = $"../../Sprite2D/AttackEffectSprite/AnimationPlayer"
@onready var audio : AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@onready var hurt_box : HurtBox = %AttackHurtBox

@onready var walk: State = $"../Walk"
@onready var idle: State = $"../Idle"
@onready var charge_attack: State = $"../ChargeAttack"

## When the player enters this state
func enter() -> void:
	player.update_animation("attack")
	sword_animation.play("attack/" + player.anim_direction())
	animation_player.animation_finished.connect(_end_attack)

	#Audio
	audio.stream = attack_sound
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()

	attacking = true

	await get_tree().create_timer(0.075).timeout
	if attacking:
		hurt_box.monitoring = true
	pass

## When the player leaves this state
func exit() -> void:
	animation_player.animation_finished.disconnect(_end_attack)
	hurt_box.monitoring = false
	pass

## During the _process update in this State
func process(_delta: float) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	return null

## During the _physics_process update in this State
func physics(_delta: float) -> State:
	return null

## Input events in this state
func handle_input(_event: InputEvent) -> State:
	return null

func _end_attack( _newAnimiationName : String) -> void:
	if Input.is_action_pressed( "attack" ):
		state_machine.change_state( charge_attack )
	attacking = false
