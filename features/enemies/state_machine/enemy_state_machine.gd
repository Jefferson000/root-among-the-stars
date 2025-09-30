class_name EnemyStateMachine extends Node

var states : Array[ EnemyState ]
var prev_state : EnemyState
var current_state : EnemyState

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	change_state(current_state.process(delta))

func _physics_process(delta: float) -> void:
	change_state(current_state.physics(delta))

func initialize(_enemy : Enemy) -> void:
	states = []

	for c in get_children():
		if c is EnemyState:
			states.append(c)

	for s in states:
		s.enemy = _enemy
		s.state_machine = self
		s.init()

	if states.size() > 0:
		change_state(states[0])
		process_mode = Node.PROCESS_MODE_INHERIT

func change_state(new_state: EnemyState) -> void:

	if new_state == null or new_state == current_state:
		return
	if current_state:
		current_state.exit()

	prev_state = current_state
	current_state = new_state
	#log_transition(current_state.enemy, prev_state, current_state)
	current_state.enter()



#*************************** LOGGING STUFF ***************************
const SHOW_TIME = false

# Ignore lists (exact string matches)
const IGNORE_STATES  := [] # ["Idle", "Wander"]
const IGNORE_ENEMIES := ["Slime", "Slime2", "Slime3"]

const COL_TS    := 19  # "YYYY-MM-DDTHH:MM:SS"
const COL_ENEMY := 12
const COL_FROM  := 12
const COL_TO    := 12

var _printed_header := false

func _fmt_cell_left(text: String, w: int) -> String:
	return text.substr(0, w).rpad(w, " ")

func _fmt_cell_right(text: String, w: int) -> String:
	return text.substr(0, w).lpad(w, " ")

func _log_header() -> void:
	var h  := _fmt_cell_left("Timestamp", COL_TS) + " | " \
			+ _fmt_cell_left("Enemy", COL_ENEMY) + " | " \
			+ _fmt_cell_left("From",  COL_FROM)  + " -> " \
			+ _fmt_cell_left("To",    COL_TO)
	var total := COL_TS + 3 + COL_ENEMY + 3 + COL_FROM + 4 + COL_TO
	print_rich("[b]", h, "[/b]")
	print("-".repeat(total))
	_printed_header = true

func log_transition(enemy: Node, from_state: EnemyState, to_state: EnemyState) -> void:
	# --- filters (early-outs) ---
	var enemy_name := str(enemy.name)
	if enemy_name in IGNORE_ENEMIES:
		return
	if from_state and str(from_state.name) in IGNORE_STATES:
		return
	if to_state and str(to_state.name) in IGNORE_STATES:
		return
	# -----------------------------

	if not _printed_header:
		_log_header()

	var ts        := Time.get_datetime_string_from_system(true)
	var from_name := (str(from_state.name) if from_state != null else "NULL")
	var to_name   := (str(to_state.name)   if to_state   != null else "NULL")

	var ts_col    := _fmt_cell_left(ts, COL_TS)
	var enemy_col := _fmt_cell_left(enemy_name, COL_ENEMY)
	var from_col  := _fmt_cell_left(from_name, COL_FROM)
	var to_col    := _fmt_cell_left(to_name, COL_TO)

	if SHOW_TIME:
		print_rich(
			"[color=gray]", ts_col, "[/color] | ",
			"[b][color=cyan]", enemy_col, "[/color][/b] | ",
			"[color=orange]", from_col, "[/color] ",
			"[color=gray]->[/color] ",
			"[color=aqua]", to_col, "[/color]"
		)
	else:
		print_rich(
			"[b][color=cyan]", enemy_col, "[/color][/b] | ",
			"[color=orange]", from_col, "[/color] ",
			"[color=gray]->[/color] ",
			"[color=aqua]", to_col, "[/color]"
		)
