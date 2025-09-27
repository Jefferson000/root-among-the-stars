class_name EnemyState extends Node

## Store a reference to the enemy that this state belongs to
var enemy : Enemy
var state_machine : EnemyStateMachine

## When we initialize this state
func init() -> void:
	pass

## When the enemy enters this state
func enter() -> void:
	pass

## When the enemy leaves this state
func exit() -> void:
	pass

## During the _process update in this State
func process(_delta: float) -> EnemyState:
	return null

## During the _physics_process update in this State
func physics(_delta: float) -> EnemyState:
	return null
