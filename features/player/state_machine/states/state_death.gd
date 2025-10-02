class_name Death_State extends State

@export var exhaust_audio : AudioStream

@onready var audio_stream_player: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

## When we initialize this state
func init() -> void:
	pass

## When the player enters this state
func enter() -> void:
	player.animation_player.play("death")
	audio_stream_player.stream = exhaust_audio
	audio_stream_player.play()
	AudioManager.play_music( null ) # here we can add music when death
	PlayerHud.show_game_over_screen()

## When the player leaves this state
func exit() -> void:
	pass

## During the _process update in this State
func process(_delta: float) -> State:
	player.velocity = Vector2.ZERO
	return null

## During the _physics_process update in this State
func physics(_delta: float) -> State:
	return null

## Input events in this state
func handle_input(_event: InputEvent) -> State:
	return null
