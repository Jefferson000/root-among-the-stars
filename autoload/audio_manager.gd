extends Node
## Crossfades background music by toggling between two AudioStreamPlayers.
## Call `play_music(stream)` to crossfade to a new track.

# --- Constants / Tunables ---
const PLAYER_COUNT: int = 2                 # Two players for ping-pong crossfading
const VOLUME_FADE_IN_DB: float = 0.0        # Target volume when fully audible
const VOLUME_FADE_OUT_DB: float = -40.0     # Floor volume when muted
const DEFAULT_MUSIC_BUS: String = "Music"

@export var music_bus: String = DEFAULT_MUSIC_BUS
@export var fade_duration_seconds: float = 0.5

# --- State ---
var active_player_idx: int = 0
var players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	# Always process so tweens run even when the scene is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Create the pool of audio players and initialize them muted on the correct bus.
	for i in PLAYER_COUNT:
		var p := AudioStreamPlayer.new()
		add_child(p)
		p.bus = music_bus
		p.volume_db = VOLUME_FADE_OUT_DB
		players.append(p)

func play_music(stream: AudioStream) -> void:
	# Ignore if there's nothing to play (alternatively, you could treat null as "stop music").
	if stream == null:
		return

	# If we're already playing this exact stream on the active player, do nothing.
	var current_player := players[active_player_idx]
	if stream == current_player.stream:
		return

	# Flip to the other player (ping-pong) and assign the new stream.
	active_player_idx = (active_player_idx + 1) % players.size()
	var next_player: AudioStreamPlayer = players[active_player_idx]

	# Ensure the next player starts from the fade-out floor, then play and fade up.
	next_player.volume_db = VOLUME_FADE_OUT_DB
	next_player.stream = stream
	_play_and_fade_in(next_player)

	# Fade out (and stop) whichever player was active before the flip.
	var previous_idx := (active_player_idx + players.size() - 1) % players.size()
	var prev_player := players[previous_idx]
	_fade_out_and_stop(prev_player)

func _play_and_fade_in(player: AudioStreamPlayer) -> void:
	player.play(0)  # Start from the beginning (seek = 0)
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", VOLUME_FADE_IN_DB, fade_duration_seconds)

func _fade_out_and_stop(player: AudioStreamPlayer) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", VOLUME_FADE_OUT_DB, fade_duration_seconds)
	await tween.finished
	player.stop()
