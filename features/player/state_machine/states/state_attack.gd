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

## When the player enters this state
func Enter() -> void:
	player.UpdateAnimation("attack")
	sword_animation.play("attack_" + player.AnimDirection())
	animation_player.animation_finished.connect(EndAttack)
	
	#Audio
	audio.stream = attack_sound
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()
	
	attacking = true
	
	await get_tree().create_timer(0.075).timeout
	hurt_box.monitoring = true
	pass
	
## When the player leaves this state
func Exit() -> void:
	animation_player.animation_finished.disconnect(EndAttack)
	hurt_box.monitoring = false
	pass

## During the _process update in this State
func Process(_delta: float) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	return null
	
## During the _physics_process update in this State
func Physics(_delta: float) -> State:
	return null
	
## Input events in this state
func HandleInput(_event: InputEvent) -> State:
	return null

func EndAttack( _newAnimiationName : String) -> void:
	attacking = false
