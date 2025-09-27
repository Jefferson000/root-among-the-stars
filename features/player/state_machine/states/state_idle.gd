class_name State_Ide extends State

@onready var walk: State = $"../Walk"
@onready var attack: State = $"../Attack"

## When the player enters this state
func Enter() -> void:
	player.UpdateAnimation("idle")
	pass
	
## When the player leaves this state
func Exit() -> void:
	pass

## During the _process update in this State
func Process(_delta: float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	return null
	
## During the _physics_process update in this State
func Physics(_delta: float) -> State:
	return null
	
## Input events in this state
func HandleInput(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	return null
