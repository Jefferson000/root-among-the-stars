class_name EnergyOrb extends Node2D

@export var speed : float = 200.0
@export var duration_alive : float = 4.0
@export var shoot_audio : AudioStream
@export var hit_audio : AudioStream

@onready var hurt_box: HurtBox = $HurtBox
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var direction : Vector2 = Vector2.DOWN

func _ready() -> void:
	hurt_box.did_damage.connect( hit_player )
	play_audio( shoot_audio )
	get_tree().create_timer( duration_alive ).timeout.connect( destroy ) # after hurting the player will desapear Xs
	direction = global_position.direction_to( PlayerManager.player.global_position )
	flicker()

func _process(delta: float) -> void:
	position += direction * speed * delta

func flicker() -> void:
	modulate.a = randf() * 0.7 + 0.3
	await get_tree().create_timer( 0.05 ).timeout
	flicker()

func hit_player() -> void:
	play_audio( hit_audio )
	destroy()

func play_audio( _a : AudioStream ) -> void:
	audio_stream_player.stream = _a
	audio_stream_player.play()

func destroy():
	queue_free()
