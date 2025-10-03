class_name PathFinder extends Node2D


@onready var timer: Timer = $Timer

var move_direction : Vector2 = Vector2.ZERO
var best_path : Vector2 = Vector2.ZERO
var rays : Array[ RayCast2D ]
var interests : Array[ float ]
var obstacles : Array[ float ] = [ 0 , 0 , 0, 0 , 0 , 0 , 0 , 0 ]
var outcomes : Array[ float ] = [ 0 , 0 , 0, 0 , 0 , 0 , 0 , 0 ]
var vectors : Array[Vector2] = [
		Vector2(0,-1), #UP
		Vector2(1,-1), #UP/RIGHT
		Vector2(1,0),  #RIGHT
		Vector2(1,1),  #DOWN/RIGHT
		Vector2(0,1),  #DOWN
		Vector2(-1,1), #DOWN/LEFT
		Vector2(-1,0), #LEFT
		Vector2(-1,-1) #UP/LEFT
]

func _ready() -> void:
	# Gather all Raycast2D Node
	for c in get_children():
		if c is RayCast2D:
			rays.append(c)

	# Normalize Vectors
	for v in vectors:
		v = v.normalized()

	# Perform initial pathfinder function
	set_path()

 	# Connect a timer
	timer.timeout.connect( set_path )

func _process( _delta: float ) -> void:
	# Gradually update move_dir towards best_path.
	# Other scripts will reference the move_dir in their movement code.
	# The "lerp" will prevent hard direction changes, and most jittering
	# or directionally confused looking behaviors from enemies.
	move_direction = lerp( move_direction, best_path, 10 * _delta )

# Set the "beth_path" vector by checking for desired direction and considering obstacles
func set_path() -> void:
	#Get direction to the player
	var player_dir : Vector2 = global_position.direction_to( PlayerManager.player.global_position )

	# Reset obstacle values to 0
	for i in 8:
		obstacles[ i ] = 0
		outcomes[ i ] = 0

	# Check each Raycast2D for collisions & update values in obstacles array
	for i in 8:
		if rays[ i ].is_colliding():
			obstacles[ i ] += 4
			obstacles[ get_next_i( i ) ] += 1
			obstacles[ get_prev_i( i ) ] += 1

	# If there are no obstacles, recommend path in direction of player
	if obstacles.max() == 0:
		best_path = player_dir
		return

	# Populate our interest array.
	# This array contains values taht represent the desireabiulity of each direction
	interests.clear()
	for v in vectors:
		# We want the dot product: A dot product is an operation that takes two vectors
		# and returns a value which represents how closely they align, essentially measuring
		# the "overlap" between their directions. Higher values means more similar vectors
		interests.append( v.dot( player_dir ) )


	# Populate outcomes array, by combining interest and obstacle arrays
	for i in 8:
		outcomes[ i ] = interests[ i ] - obstacles[ i ]

	# Set the best path with the Vector2 that corresponds with the hughest outcome calue
	best_path = vectors[ outcomes.find( outcomes.max() ) ]


# Returns the next index value, wrapping at 8
func get_next_i( i : int ) -> int:
	var n_i : int = i + 1
	if n_i >= 8:
		return 0
	else:
		return n_i

# Returns the previous index value, wrapping at -1
func get_prev_i( i : int ) -> int:
	var n_i : int = i - 1
	if n_i < 0:
		return 7
	else:
		return n_i
