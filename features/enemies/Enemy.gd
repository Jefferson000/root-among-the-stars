class_name Enemy extends CharacterBody2D

const DIR_4: Array[Vector2] = [
	Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP
]
const FACE_BIAS := 0.10

signal direction_changed( new_direction : Vector2)
signal enemy_damaged()

@export var hp : int = 3

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var state_machine : EnemyStateMachine = $EnemyStateMachine

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var player : Player
var invulnerable : bool = false


func _ready() -> void:
	state_machine.Initalize( self )
	player = PlayerManager.player


func _physics_process(_delta: float) -> void:
	move_and_slide()
	
	
func set_direction( _new_direction : Vector2) -> bool:
	direction = _new_direction
	if direction == Vector2.ZERO:
		return false

	var d := (direction + cardinal_direction * FACE_BIAS).normalized()

	var best_i := 0
	var best_dot := -INF
	for i in DIR_4.size():
		var dot := d.dot(DIR_4[i])
		if dot > best_dot:
			best_dot = dot
			best_i = i

	var new_dir: Vector2 = DIR_4[best_i]  # or := if DIR_4 is typed

	if new_dir == cardinal_direction:
		return false

	cardinal_direction = new_dir
	direction_changed.emit(new_dir)
	sprite.scale.x = -1 if new_dir == Vector2.LEFT else 1
	return true

func update_animation(state: String) -> void:
	animation_player.play(state + "_" + anim_direction())
	
	
func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"
