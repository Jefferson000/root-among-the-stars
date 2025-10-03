@tool
extends NPCBehavior

const DIRECTIONS = [ Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
@export var wander_range : int = 2 : set = _set_wander_range
@export var wander_speed : float = 30
@export var wander_duration : float = 1.0
@export var idle_duration : float = 1.0

var original_position : Vector2

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()
	$CollisionShape2D.queue_free()
	original_position = npc.global_position

func _process( _delta: float ) -> void:
	if Engine.is_editor_hint():
		return
	#if abs( global_position.distance_to( original_position ) ) > wander_range * 32:
		#npc.velocity *= -1
		#npc.direction *= -1
		#npc.update_direction( global_position + npc.direction )
		#npc.update_animation()


func start() -> void:
	# IDLE PHASE
	if npc.do_behavior == false:
		return
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc.update_animation()
	await get_tree().create_timer( randf() * idle_duration + idle_duration * 0.5 ).timeout
	if npc.do_behavior == false:
		return

	# WALK PHASE
	npc.state = "walk"
	var direction : Vector2 = DIRECTIONS[ randi_range( 0, 3 ) ]
	if abs( global_position.distance_to( original_position ) ) > wander_range * 32:
		var dir_to_area : Vector2 = global_position.direction_to( original_position )
		var best_directions : Array[ float ]
		for d in DIRECTIONS:
			best_directions.append( d.dot( dir_to_area ) )
		direction = DIRECTIONS[ best_directions.find( best_directions.max() ) ]
		print(direction)

	npc.direction = direction
	npc.velocity = wander_speed * direction
	npc.update_direction( global_position + direction )
	npc.update_animation()
	await get_tree().create_timer( randf() * wander_duration + wander_duration * 0.5 ).timeout

	# REPEAT
	if npc.do_behavior == false:
		return
	start()

func _set_wander_range( value : int ) -> void:
	wander_range = value
	$CollisionShape2D.shape.radius = value * 32.0
