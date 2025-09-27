class_name State_Ide extends State

@onready var walk: State = $"../Walk"
@onready var attack: State = $"../Attack"

## When the player enters this state
func enter() -> void:
	player.update_animation("idle")
	pass
	
## When the player leaves this state
func exit() -> void:
	pass

## During the _process update in this State
func process(_delta: float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	return null
	
## During the _physics_process update in this State
func physics(_delta: float) -> State:
	return null
	
## Input events in this state
func handle_input(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	return null
