class_name State extends Node

static var player : Player

## When the player enters this state
func enter() -> void:
	pass

## When the player leaves this state
func exit() -> void:
	pass

## During the _process update in this State
func process(_delta: float) -> State:
	return null

## During the _physics_process update in this State
func physics(_delta: float) -> State:
	return null

## Input events in this state
func handle_input(_event: InputEvent) -> State:
	return null
