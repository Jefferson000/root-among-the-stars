class_name DarkWizardBoss extends Node2D

const ENERGY_EXPLOSION_SCENE : PackedScene = preload("res://levels/dungeon/dark_wizard/energy_explosion.tscn")
const ENERGY_ORB_SCENE : PackedScene = preload("res://levels/dungeon/dark_wizard/energy_orb/energy_orb.tscn")

@export var max_hp : int = 10

@onready var persistent_data_handler: PersistentDataHandler = $PersistentDataHandler
@onready var audio_stream_player: AudioStreamPlayer2D = $BossNode/AudioStreamPlayer2D
@onready var boss_node: Node2D = $BossNode
@onready var animation_player: AnimationPlayer = $BossNode/AnimationPlayer
@onready var cloak_animation_player: AnimationPlayer = $BossNode/CloakSprite/AnimationPlayer
@onready var animation_player_damaged: AnimationPlayer = $BossNode/AnimationPlayer_Damaged
@onready var hit_box: HitBox = $BossNode/HitBox
@onready var hurt_box: HurtBox = $BossNode/HurtBox

@onready var hand_01: Sprite2D = $BossNode/CloakSprite/Hand01
@onready var hand_02: Sprite2D = $BossNode/CloakSprite/Hand02
@onready var hand_01_up: Sprite2D = $BossNode/CloakSprite/Hand01_UP
@onready var hand_02_up: Sprite2D = $BossNode/CloakSprite/Hand02_UP
@onready var hand_01_side: Sprite2D = $BossNode/CloakSprite/Hand01_SIDE
@onready var hand_02_side: Sprite2D = $BossNode/CloakSprite/Hand02_SIDE
@onready var door_block: TileMapLayer = $"../DoorBlock"


var hp : int = 10
var current_position : int = 0
var positions : Array[ Vector2 ]
var audio_hurt : AudioStream = preload("res://levels/dungeon/dark_wizard/audio/boss_hurt.wav")
var audio_orb : AudioStream = preload("res://levels/dungeon/dark_wizard/audio/boss_fireball.wav")
var beam_attacks : Array[ EnergyBeam ]
var damage_count : int = 0

func _ready() -> void:
	persistent_data_handler.get_value()
	if persistent_data_handler.value:
		door_block.enabled = false
		queue_free()
		return

	hp = max_hp
	PlayerHud.show_boss_ui( "Dark Wizard" )

	hit_box.damaged.connect( _damage_taken )

	for c in $PositionTagets.get_children():
		positions.append( c.global_position )
	print(positions)
	$PositionTagets.visible = false
	#We can queue free the positoins

	for b in $BeamAttacks.get_children():
		beam_attacks.append( b )

	teleport(0)

func _process( _delta: float ) -> void:
	hand_01_up.position = hand_01.position
	hand_01_up.frame = hand_01.frame + 4
	hand_02_up.position = hand_02.position
	hand_02_up.frame = hand_02.frame + 4

	hand_01_side.position = hand_01.position
	hand_01_side.frame = hand_01.frame + 8
	hand_02_side.position = hand_02.position
	hand_02_side.frame = hand_02.frame + 12

func teleport( _location : int ) -> void:
	damage_count = 0
	animation_player.play( "disappear" )
	enable_boxes( false )

	if hp < max_hp:
		energy_orb_attack()

	await get_tree().create_timer( 1 ).timeout

	boss_node.global_position = positions[ _location ]
	current_position = _location

	update_animations()

	animation_player.play( "appear" )
	await animation_player.animation_finished
	idle()

func idle() -> void:
	#energy_beam_attack() #More dificulty
	#energy_orb_attack() # More dificulty
	enable_boxes()

	#ranm idle animation before shooting
	if randf() <= float(hp) / float(max_hp):
		animation_player.play( "idle" )
		await animation_player.animation_finished
		if hp < 1:
			return

	if damage_count < 1:
		energy_beam_attack()
		animation_player.play("cast_spell")
		await animation_player.animation_finished
		if hp < 1:
			return

	if hp < 1:
		return

	var _t : int = current_position
	while _t == current_position:
		_t = randi_range(0 , 3)

	teleport( _t )

func _damage_taken( _hurt_box : HurtBox ) -> void:
	if animation_player_damaged.current_animation == "damaged" or _hurt_box.damage == 0:
		return

	play_audio(audio_hurt)
	hp = clampi( hp - _hurt_box.damage, 0, max_hp )
	damage_count += 1

	PlayerHud.update_boss_health( hp, max_hp )
	animation_player_damaged.play("damaged")
	animation_player_damaged.seek( 0 )
	animation_player_damaged.queue("default")
	if hp < 1 :
		defeat()

func play_audio( _a : AudioStream ) -> void:
	audio_stream_player.stream = _a
	audio_stream_player.play()

func defeat() -> void:
	animation_player.play("destroy")
	enable_boxes( false )
	PlayerHud.hide_boss_ui()
	persistent_data_handler.set_value()
	await animation_player.animation_finished
	door_block.enabled = false

func enable_boxes( _v : bool = true ) -> void:
	hit_box.set_deferred( "monitorable", _v )
	hurt_box.set_deferred( "monitoring", _v )

func explision( _p : Vector2 = Vector2.ZERO ) -> void:
	var e : Node2D = ENERGY_EXPLOSION_SCENE.instantiate()
	e.global_position = boss_node.global_position + _p
	get_parent().add_child.call_deferred( e )

func update_animations() -> void:
	print(current_position)

	hand_01.visible = false
	hand_02.visible = false
	hand_01_side.visible = false
	hand_02_side.visible = false
	hand_01_up.visible = false
	hand_02_up.visible = false
	boss_node.scale = Vector2( 1, 1 )
	if current_position == 0:
		cloak_animation_player.play("down")
		hand_01.visible = true
		hand_02.visible = true
	elif current_position == 2:
		cloak_animation_player.play("up")
		hand_01_up.visible = true
		hand_02_up.visible = true
	else:
		cloak_animation_player.play("side")
		hand_01_side.visible = true
		hand_02_side.visible = true
		if current_position == 1:
			boss_node.scale = Vector2( -1, 1 )

func energy_orb_attack() -> void:
	var eb : Node2D = ENERGY_ORB_SCENE.instantiate()
	eb.global_position = boss_node.global_position + Vector2( 0 , -34 )
	get_parent().add_child.call_deferred( eb )
	play_audio( audio_orb )

func energy_beam_attack() -> void:
	var _b : Array[ int ]
	match current_position:
		0, 2:
			if current_position == 0:
				_b.append( 0 )
				_b.append( randi_range( 1, 2 ) )
			else:
				_b.append( 2 )
				_b.append( randi_range( 0, 1 ) )
			if hp < 5:
				_b.append( randi_range( 3, 5 ) )
		1, 3:
			if current_position == 3:
				_b.append( 5 )
				_b.append( randi_range( 3, 4 ) )
			else:
				_b.append( 3 )
				_b.append( randi_range( 4, 5 ) )
			if hp < 5:
				_b.append( randi_range( 0, 3 ) )
	for b in _b:
		beam_attacks[ b ].attack()
