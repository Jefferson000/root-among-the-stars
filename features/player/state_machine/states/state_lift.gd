class_name State_Lift extends State

@export var lift_audio : AudioStream
@onready var carry_state : State = $"../Carry"

## When the player enters this state
func enter() -> void:
	player.update_animation("lift")
	player.animation_player.animation_finished.connect( state_complete )
	player.audio.stream = lift_audio
	player.audio.play()

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

func state_complete( _a : String ) -> void:
	player.animation_player.animation_finished.disconnect( state_complete )
	state_machine.change_state( carry_state )
