class_name Carry_State extends State

@export var move_speed : float = 100.0
@export var throw_audio : AudioStream

@onready var idle_state: State_Ide = $"../Idle"
@onready var stun_state: State_Stun = $"../Stun"

var walking : bool = false
var throwable : Throwable

## When we initialize this state
func init() -> void:
	pass

## When the player enters this state
func enter() -> void:
	player.update_animation( "carry_idle" )
	walking = false

## When the player leaves this state
func exit() -> void:
	if throwable:
		if player.direction == Vector2.ZERO:
			throwable.throw_direction = player.cardinal_direction
		else:
			throwable.throw_direction = player.direction

		if state_machine.next_state == stun_state:
			throwable.throw_direction = throwable.throw_direction.rotated( PI )
			throwable.drop()
		else:
			player.audio.stream = throw_audio
			player.audio.play()
			throwable.throw()
	pass

## During the _process update in this State
func process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		walking = false
		player.update_animation( "carry_idle" )
	elif player.set_direction() or walking == false:
		player.update_animation( "carry_walk" )
		walking = true
	player.velocity = player.direction * move_speed
	return null

## During the _physics_process update in this State
func physics(_delta: float) -> State:
	return null

## Input events in this state
func handle_input(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack") or _event.is_action_pressed("interact"):
		return idle_state
	return null
