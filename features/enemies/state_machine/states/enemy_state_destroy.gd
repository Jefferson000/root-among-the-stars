class_name EnemyStateDestroy extends EnemyState

@export var anim_name : String = "destroy"
@export var knockback_speed : float = 200.0
@export var decelerate_speed : float = 10.0

@export_category("IA")

var _direction : Vector2
var _damage_position : Vector2

## When we initialize this state
func init() -> void:
	enemy.enemy_destroy.connect(_on_enemy_destroy)

## When the enemy enters this state
func enter() -> void:
	enemy.invulnerable = true

	_direction = enemy.global_position.direction_to( _damage_position )

	enemy.set_direction(_direction)
	enemy.velocity = _direction * -knockback_speed

	enemy.update_animation( anim_name )
	enemy.animation_player.animation_finished.connect( _on_animation_finished )
	disable_hurt_box()

## When the enemy leaves this state
func exit() -> void:
	enemy.invulnerable = false
	enemy.animation_player.animation_finished.disconnect( _on_animation_finished )

## During the _process update in this State
func process(_delta: float) -> EnemyState:
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta
	return null

## During the _physics_process update in this State
func physics(_delta: float) -> EnemyState:
	return null

func _on_enemy_destroy( hurt_box : HurtBox ) -> void:
	_damage_position = hurt_box.global_position
	state_machine.change_state(self)

func _on_animation_finished( _a : String) -> void:
	enemy.queue_free()

func disable_hurt_box() -> void:
	var hurt_box : HurtBox = enemy.get_node_or_null("HurtBox")
	if hurt_box:
		hurt_box.monitoring = false
