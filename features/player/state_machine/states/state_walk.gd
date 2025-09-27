class_name State_Walk extends State

@export var move_speed: float = 100.0
@onready var idle: State = $"../Idle"
@onready var attack: State = $"../Attack"

func Enter() -> void:
	player.UpdateAnimation("walk")

func Exit() -> void:
	pass

# No movement here to avoid duplicates
func Process(_delta: float) -> State:
	return null

func Physics(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		player.velocity = Vector2.ZERO
		return idle

	var dir := player.direction.normalized()
	player.velocity = dir * move_speed

	if player.SetDirection():
		player.UpdateAnimation("walk")
	return null

func HandleInput(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	return null
