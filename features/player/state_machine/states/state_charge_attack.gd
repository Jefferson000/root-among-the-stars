class_name State_ChargeAttack extends State

@onready var idle: State_Ide = $"../Idle"
@onready var charge_attack_hurt_box: HurtBox = $"../../Sprite2D/ChargeHurtBox"
@onready var charge_spin_hurt_box: HurtBox = %SpinHurtBox
@onready var audio_stream_player: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@onready var spin_effect_sprite: Sprite2D = $"../../Sprite2D/SpinEffectSprite2D"
@onready var spin_animation_player: AnimationPlayer = $"../../Sprite2D/SpinEffectSprite2D/AnimationPlayer"
@onready var gpu_particles: GPUParticles2D = $"../../Sprite2D/ChargeHurtBox/GPUParticles2D"

@export var charge_duration : float = 1.0
@export var move_speed : float = 80.0
@export var sfx_charged : AudioStream
@export var sfx_spin : AudioStream


var timer : float = 0.0
var walking : bool = false
var is_attacking : bool = false
var particles : ParticleProcessMaterial

## When we initialize this state
func init() -> void:
	gpu_particles.emitting = false
	particles = gpu_particles.process_material as ParticleProcessMaterial
	spin_effect_sprite.visible = false
	pass

## When the player enters this state
func enter() -> void:
	gpu_particles.emitting = true
	timer = charge_duration
	is_attacking = false
	walking = false
	charge_attack_hurt_box.monitoring = true
	gpu_particles.amount = 4
	gpu_particles.explosiveness = 0
	particles.initial_velocity_min = 10
	particles.initial_velocity_max = 30

	pass

## When the player leaves this state
func exit() -> void:
	charge_attack_hurt_box.monitoring = false
	charge_spin_hurt_box.monitoring = false
	spin_effect_sprite.visible = false
	gpu_particles.emitting = false


## During the _process update in this State
func process( _delta: float ) -> State:
	if timer > 0:
		timer -= _delta
		if timer <= 0:
			timer = 0
			charge_complete()

	if is_attacking == false:
		if player.direction == Vector2.ZERO:
			walking = false
			player.update_animation( "charge" )
		elif player.set_direction() or walking == false:
			walking = true
			player.update_animation( "charge_walk" )


	player.velocity = player.direction * move_speed
	return null

## During the _physics_process update in this State
func physics(_delta: float) -> State:
	return null

## Input events in this state
func handle_input(_event: InputEvent) -> State:
	if _event.is_action_released( "attack" ):
		if timer > 0:
			return idle
		elif is_attacking == false:
			charge_attack()
	return null

func charge_attack() -> void:
	is_attacking = true
	player.animation_player.play( "charge/attack" )
	player.animation_player.seek( get_spin_frame() )
	play_audio( sfx_spin )
	spin_effect_sprite.visible = true
	spin_animation_player.play( "spin" )
	var _duration : float = player.animation_player.current_animation_length

	player.make_invulnerable( _duration )

	charge_spin_hurt_box.monitoring = true

	await get_tree().create_timer( _duration * 0.875 ).timeout

	state_machine.change_state( idle )

func get_spin_frame() -> float:
	var interval : float = 0.05
	match player.cardinal_direction:
		Vector2.DOWN:
			return interval * 0
		Vector2.UP:
			return interval * 4
		_:
			return interval * 6

func charge_complete() -> void:
	play_audio( sfx_charged )
	gpu_particles.amount = 50
	gpu_particles.explosiveness = 1
	particles.initial_velocity_min = 50
	particles.initial_velocity_max = 100

	await get_tree().create_timer( 0.5 ).timeout

	gpu_particles.amount = 50
	gpu_particles.explosiveness = 0
	particles.initial_velocity_min = 10
	particles.initial_velocity_max = 30



func play_audio( _audio : AudioStream ) -> void:
	audio_stream_player.stream = _audio
	audio_stream_player.play()
