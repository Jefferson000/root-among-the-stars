class_name Player extends CharacterBody2D

const DIR_4: Array[Vector2] = [
	Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP
]
const FACE_BIAS := 0.10

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO

@onready var sprite : Sprite2D = $Sprite2D
@onready var hit_box : HitBox = $HitBox
@onready var state_machine : PlayerStateMachine = $StateMachine
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var effect_animation_player : AnimationPlayer = $EffectAnimationPlayer
@onready var audio: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D
@onready var lift_state: State_Lift = $StateMachine/Lift
@onready var lifted_item: Node2D = $Sprite2D/LiftedItem
@onready var carry_state: State = $StateMachine/Carry


signal direction_changed( new_direction: Vector2 )
signal player_damage( hurt_box : HurtBox )

var invulnerable : bool = false
var hp : int = 6
var max_hp : int = 6

func _ready() -> void:
	PlayerManager.player = self
	state_machine.initialize(self)
	hit_box.damaged.connect( _take_damage )
	update_hp(99)

func _process(_delta: float) -> void:
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("test"):

		## Auto Kill Test
		#update_hp(-99)
		#player_damage.emit( %AttackHurtBox )

		## Camara Test
		#PlayerManager.shake_camara()

		pass

func set_direction() -> bool:
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
	var animation : String = state + "/" + anim_direction()
	#print( animation )
	animation_player.play( animation )

func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"

func _take_damage( hurt_box : HurtBox ) -> void:
	if invulnerable:
		return
	if hp > 0:
		update_hp( -hurt_box.damage )
		player_damage.emit( hurt_box )

func update_hp( delta : int ) -> void:
	hp = clampi( hp + delta, 0, max_hp )
	PlayerHud.update_hp( hp, max_hp )

func make_invulnerable( _duration : float = 1.0 ) -> void:
	invulnerable = true
	hit_box.monitoring = false
	await get_tree().create_timer( _duration ).timeout

	invulnerable = false
	hit_box.monitoring = true

func pickup_item( _t : Throwable ) -> void:
	state_machine.change_state( lift_state )
	carry_state.throwable = _t

func revive_player() -> void:
	update_hp(99)
	state_machine.change_state( $StateMachine/Idle )
