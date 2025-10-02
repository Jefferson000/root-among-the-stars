class_name State_Walk extends State

@export var move_speed: float = 100.0
@onready var idle: State = $"../Idle"
@onready var attack: State = $"../Attack"

func enter() -> void:
	player.update_animation("walk")

func exit() -> void:
	pass

# No movement here to avoid duplicates
func process(_delta: float) -> State:
	return null

func physics(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		player.velocity = Vector2.ZERO
		return idle

	var dir := player.direction.normalized()
	player.velocity = dir * move_speed

	if player.set_direction():
		player.update_animation("walk")
	return null

func handle_input(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	elif _event.is_action_pressed("interact"):
		PlayerManager.interact()
	return null
