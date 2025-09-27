class_name EnemyStateIdle extends EnemyState

@export var anim_name : String = "idle"
@export_category("IA")
@export var state_duration_min : float = 0.5
@export var state_duration_max : float = 1.5
@export var after_idle_state : EnemyState

var _timer : float = 0.0

## When we initialize this state
func init() -> void:
	pass

## When the enemy enters this state
func enter() -> void:
	enemy.velocity = Vector2.ZERO
	_timer = randf_range(state_duration_min, state_duration_max)
	enemy.update_animation(anim_name)
	pass
	
## When the enemy leaves this state
func exit() -> void:
	pass

## During the _process update in this State
func process(_delta: float) -> EnemyState:
	_timer -= _delta
	if _timer <= 0:
		return after_idle_state
	return null
	
## During the _physics_process update in this State
func physics(_delta: float) -> EnemyState:
	return null
