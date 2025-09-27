class_name State extends Node

static var player : Player

## When the player enters this state
func Enter() -> void:
	pass
	
## When the player leaves this state
func Exit() -> void:
	pass

## During the _process update in this State
func Process(_delta: float) -> State:
	return null
	
## During the _physics_process update in this State
func Physics(_delta: float) -> State:
	return null
	
## Input events in this state
func HandleInput(_event: InputEvent) -> State:
	return null
