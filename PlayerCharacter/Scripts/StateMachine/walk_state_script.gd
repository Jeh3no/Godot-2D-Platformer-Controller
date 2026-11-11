extends State

class_name WalkState

var state_name: String = "WalkState"

@export var play_char_ref: CharacterBody2D


func enter() -> void:
	play_char_ref.animation_player.stop()

	play_char_ref.move_speed = play_char_ref.walk_speed
	play_char_ref.move_accel = play_char_ref.walk_accel
	play_char_ref.move_deccel = play_char_ref.walk_deccel

	if !play_char_ref.is_on_floor():
		transitioned.emit(self, "FallState")
	else:
		play_char_ref.nb_jumps_allowed = play_char_ref.nb_jumps_allowed_ref
		play_char_ref.animate(2, true)


func update(_delta: float) -> void:
	if play_char_ref.jump_buffering_enabled:
		play_char_ref.jump_buffering_enabled = false
		transitioned.emit(self, "JumpState")


func physics_update(delta: float) -> void:
	input()

	move(delta)

	if !play_char_ref.is_on_floor():
		transitioned.emit(self, "FallState")


func input() -> void:
	if Input.is_action_just_pressed(play_char_ref.jump_action):
		if play_char_ref.nb_jumps_allowed > 0 and play_char_ref.jump_cooldown <= 0.0:
			transitioned.emit(self, "JumpState")


func move(delta: float) -> void:
	var move_dir: float = Input.get_axis(
		play_char_ref.move_left_action,
		play_char_ref.move_right_action,
	)

	if move_dir:
		play_char_ref.velocity.x = lerp(
			play_char_ref.velocity.x,
			move_dir * play_char_ref.move_speed,
			play_char_ref.move_accel * delta,
		)
	else:
		transitioned.emit(self, "IdleState")
