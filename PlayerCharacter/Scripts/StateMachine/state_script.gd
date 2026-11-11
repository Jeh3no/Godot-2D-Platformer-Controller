extends Node

class_name State

#it's normal if this signal isn't used in this script,
#because it's purpose is to be used in the scripts that extends from the State class
signal transitioned


func enter() -> void:
	#enter state
	pass


func exit() -> void:
	#exit state
	pass


func update(_delta: float) -> void:
	#process update
	pass


func physics_update(_delta: float) -> void:
	#physics_process update
	pass
